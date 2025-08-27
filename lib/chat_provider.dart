import 'package:flutter/material.dart';
import 'chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  final List<String> _messages = [];
  List<String> get messages => _messages;

  Future<void> init() async {
    await _chatService.connect();

    _chatService.messages.listen((msg) {
      _messages.add(msg);
      notifyListeners();
    });
  }

  void sendMessage(String text) {
    _chatService.sendMessage(text);
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }
}
