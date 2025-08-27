import 'dart:async';
import 'package:phoenix_socket/phoenix_socket.dart';

class OrderService {
  late PhoenixSocket _socket;
  late PhoenixChannel _channel;

  final _updatesController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get updates => _updatesController.stream;

  Future<void> connect(String orderId) async {
    // Connect to your backend WebSocket
    _socket = PhoenixSocket("wss://www.incubator-backend.doyo.ch/new_ws/websocket");

    await _socket.connect();

    // Join specific order topic
    _channel = _socket.addChannel(topic: "order:$orderId");

    final joinPush = _channel.join();

    joinPush.future.then((reply) {
      print("Joined channel successfully: ${reply.response}");
    }).catchError((err) {
      print("Failed to join channel: $err");
    });

    // Listen for updates
    _channel.messages.listen((event) {
      print("Received event: ${event.event}, payload: ${event.payload}");
      _updatesController.add(event.payload);
    });
  }

  void dispose() {
    _updatesController.close();
    _socket.dispose();
  }
}
