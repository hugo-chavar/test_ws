import 'dart:async';
import 'package:phoenix_socket/phoenix_socket.dart';
import 'storage_service.dart';

class OrderService {
  PhoenixSocket? _socket;
  PhoenixChannel? _channel;

  final _updatesController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get updates => _updatesController.stream;
  final storage = StorageService();

  Future<void> connect(String orderId) async {
    // Dispose any previous socket
    _socket?.dispose();
    _updatesController.add({"info": "Connecting to order:31:$orderId ..."});

    try {
      bool error = await connectToSocket();

      if (error) return;


      joinToOrderStatusChannel(orderId);

    } catch (e) {
      _updatesController.add({"error": "Connection failed: $e"});
    }
  }

  void joinToOrderStatusChannel(String orderId) {
    _channel = _socket!.addChannel(topic: "order:31:$orderId");
    
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
  }


  Future<bool> connectToSocket() async {
    bool error = false;
    try {
      String? url = await storage.readString('ws_url');
      if (url == null) {
        throw "Can not find URL";
      }
      _socket = PhoenixSocket(
        url,
        socketOptions: PhoenixSocketOptions(
          heartbeat: Duration(minutes: 2, seconds: 30),
          heartbeatTimeout: Duration(seconds: 10),
        ),
      );
      await _socket!.connect();
    } catch (e) {
      _updatesController.add({"error": "Socket connection failed: $e"});
      error = true;
    }
    return error;
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


//flutter run -d chrome  --web-hostname localhost --web-port 62630