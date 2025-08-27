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
  final TextEditingController _controller = TextEditingController();

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

  void _connectToOrder() {
    final orderId = _controller.text.trim();
    if (orderId.isNotEmpty) {
      _messages.clear();
      _orderService.connect(orderId);
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
        appBar: AppBar(title: const Text("Order Updates")),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: "Enter Order ID",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _connectToOrder,
                    child: const Text("Connect"),
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
