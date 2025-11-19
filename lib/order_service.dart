import 'dart:async';
import 'package:phoenix_socket/phoenix_socket.dart';
import 'storage_service.dart';

class OrderService {
  PhoenixSocket? _socket;
  final Map<String, PhoenixChannel> _channels = {};
  
  final _updatesController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get updates => _updatesController.stream;
  final storage = StorageService();

  Future<void> connectToSocket() async {
    // Only connect if socket doesn't exist or is disconnected
    if (_socket != null && _socket!.isConnected) {
      return;
    }

    try {
      String? url = await storage.readString('ws_url');
      if (url == null) {
        throw "Cannot find URL";
      }
      
      _socket?.dispose(); // Clean up previous socket if exists
      
      _socket = PhoenixSocket(
        url,
        socketOptions: PhoenixSocketOptions(
          heartbeat: Duration(minutes: 2, seconds: 30),
          heartbeatTimeout: Duration(seconds: 10),
        ),
      );

      // Listen to socket connection state changes instead of messages
      _socket!.connectionStream.listen((state) {
        _updatesController.add({
          "type": "socket", // differentiate from other sources
          "event": "connection_state",
          "state": state.toString(),
        });
      });

      await _socket!.connect();
      _updatesController.add({"info": "Socket connected successfully"});
      
    } catch (e) {
      _updatesController.add({"error": "Socket connection failed: $e"});
      rethrow;
    }
  }

  Future<void> joinChannel(String topic, {Map<String, dynamic>? params}) async {
    if (_socket == null || !_socket!.isConnected) {
      await connectToSocket();
    }

    // Check if already joined to this channel
    if (_channels.containsKey(topic)) {
      _updatesController.add({"info": "Already joined to channel: $topic"});
      return;
    }

    try {
      final channel = _socket!.addChannel(topic: topic, parameters: params);
      _channels[topic] = channel;

      final joinPush = channel.join();
      
      final reply = await joinPush.future;
      _updatesController.add({
        "info": "Joined channel: $topic",
        "status": reply.status,
        "response": reply.response
      });

      // Listen to channel messages
      channel.messages.listen((event) {
        _updatesController.add({
          "type": "channel",
          "topic": topic,
          "event": event.event.value,
          "payload": event.payload,
        });
      }, onError: (err) {
        _updatesController.add({
          "error": "Channel $topic listen error: $err",
          "topic": topic
        });
      });

    } catch (e) {
      _channels.remove(topic);
      _updatesController.add({
        "error": "Failed to join channel $topic: $e",
        "topic": topic
      });
      rethrow;
    }
  }

  Future<void> leaveChannel(String topic) async {
    final channel = _channels[topic];
    if (channel != null) {
      try {
        channel.leave();
        _channels.remove(topic);
        _updatesController.add({"info": "Left channel: $topic"});
      } catch (e) {
        _updatesController.add({
          "error": "Failed to leave channel $topic: $e",
          "topic": topic
        });
      }
    }
  }

  // Convenience methods for specific channels
  Future<void> joinOrderStatusChannel(String orderId) {
    return joinChannel("order:31:$orderId");
  }

  Future<void> joinUserChannel(String userId) {
    return joinChannel("user:$userId", params: {"user_id": userId});
  }

  Future<void> joinNotificationsChannel() {
    return joinChannel("notifications:global");
  }

  // Check if connected to a specific channel
  bool isJoinedToChannel(String topic) {
    return _channels.containsKey(topic);
  }

  // Get all active channels
  List<String> getActiveChannels() {
    return _channels.keys.toList();
  }

  void disconnect() {
    // Leave all channels
    for (final channel in _channels.values) {
      channel.leave();
    }
    _channels.clear();
    
    _socket?.dispose();
    _updatesController.add({"info": "Disconnected from server"});
  }

  void dispose() {
    disconnect();
    _updatesController.close();
  }
}