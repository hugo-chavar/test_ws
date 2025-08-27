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
      _socket = PhoenixSocket("wss://www.incubator-backend.doyo.ch/new_ws/websocket");
      await _socket!.connect();
      _channel = _socket!.addChannel(topic: "order:$orderId");

      final joinPush = _channel!.join();

      joinPush.future.then((reply) {
        _updatesController.add({"info": "Joined channel: ${reply.response}"});
      }).catchError((err) {
        _updatesController.add({"error": "Join error: $err"});
      });

      _channel!.messages.listen((event) {
        _updatesController.add({
          "event": event.event.value,
          "payload": event.payload,
        });
      });
    } catch (e) {
      _updatesController.add({"error": "Connection failed: $e"});
    }
  }

  void dispose() {
    _updatesController.close();
    _socket?.dispose();
  }
}
