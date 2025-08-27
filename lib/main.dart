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

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    // 👉 Replace with real order ID
    await _orderService.connect("68ad1a529d321781a486f2a5");

    _orderService.updates.listen((payload) {
      setState(() {
        // Pretty print JSON like Postman
        final pretty = const JsonEncoder.withIndent("  ").convert(payload);
        _messages.add(pretty);
      });
    });
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
        body: ListView.builder(
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
    );
  }
}
