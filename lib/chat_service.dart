import 'dart:async';
import 'package:phoenix_socket/phoenix_socket.dart';

class ChatService {
  final _messagesController = StreamController<String>.broadcast();
  Stream<String> get messages => _messagesController.stream;

  late PhoenixSocket _socket;
  late PhoenixChannel _channel;

  Future<void> connect() async {
    _socket = PhoenixSocket("wss://www.incubator-backend.doyo.ch/new_ws/websocket");

    await _socket.connect();

    _channel = _socket.addChannel(topic: "order:31:68af1b7dfc1527bdc30ff112");
    await _channel.join().future;

    // Listen for events from the channel
    _channel.messages.listen((event) {
      if (event.event.value == "update") {
        final body = event.payload["body"] ?? "";
        _messagesController.add(body);
      }
    });
  }

  void sendMessage(String message) {
    _channel.push("new_msg", {"body": message});
  }

  void dispose() {
    _messagesController.close();
    _socket.dispose();
  }
}
