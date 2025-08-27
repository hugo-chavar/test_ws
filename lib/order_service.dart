import 'dart:async';
import 'package:phoenix_socket/phoenix_socket.dart';

class OrderService {
  PhoenixSocket? _socket;
  PhoenixChannel? _channel;

  final _updatesController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get updates => _updatesController.stream;

  Future<void> connect(String orderId) async {
    // Dispose any previous socket
    _socket?.dispose();
    _updatesController.add({"info": "Connecting to order:$orderId ..."});

    try {
      try {
        _socket = PhoenixSocket(
          "wss://www.incubator-backend.doyo.ch/new_ws/websocket",
          socketOptions: PhoenixSocketOptions(
            heartbeat: Duration(seconds: 30),
            heartbeatTimeout: Duration(seconds: 10),
          ),
        );
        await _socket!.connect();
      } catch (e) {
        _updatesController.add({"error": "Socket connection failed: $e"});
        return;
      }
      _channel = _socket!.addChannel(topic: "order:$orderId");

      final joinPush = _channel!.join();

      joinPush.future.then((reply) {
        _updatesController.add({"info": "Joined channel: ${reply.response}"});
      }).catchError((err) {
        _updatesController.add({"error": "Join error: $err"});
      });

      _channel!.messages.listen(
        (event) {
          _updatesController.add({
            "event": event.event.value,
            "payload": event.payload,
          });
        },
        onError: (err) {
          _updatesController.add({"error": "Channel listen error: $err"});
        },
      );

    } catch (e) {
      _updatesController.add({"error": "Connection failed: $e"});
    }
  }

  void disconnect() {
    _channel?.leave();
    _socket?.dispose();
    _updatesController.add({"info": "Disconnected from server"});
  }

  void dispose() {
    _updatesController.close();
    _socket?.dispose();
  }
}
