import 'dart:convert';
import 'package:flutter/material.dart';
import 'order_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final OrderService _orderService = OrderService();
  final List<String> _messages = [];
  final TextEditingController _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    _orderService.updates.listen((payload) {
      setState(() {
        // Pretty print JSON
        final pretty = const JsonEncoder.withIndent("  ").convert(payload);
        _messages.add(pretty);
      });
    });
  }

  void _connectToChannel() {
    final topic = _topicController.text.trim();
    if (topic.isNotEmpty) {
      // _messages.clear();
      _orderService.joinChannel(topic);
    }
  }

  void _leaveChannel() {
    final topic = _topicController.text.trim();
    if (topic.isNotEmpty) {
      // _messages.clear();
      _orderService.leaveChannel(topic);
    }
  }

  @override
  void dispose() {
    _orderService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Channel Updates")),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: "Enter topic",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _connectToChannel,
                    child: const Text("Connect"),
                  ),
                  ElevatedButton(
                    onPressed: _leaveChannel,
                    child: const Text("Leave"),
                  ),
                  ElevatedButton(
                    onPressed: () => _orderService.disconnect(),
                    child: Text("Disconnect"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _messages[index],
                        style: const TextStyle(fontFamily: "monospace"),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
