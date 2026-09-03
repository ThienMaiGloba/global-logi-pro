import 'package:flutter/material.dart';

class DispatchScreen extends StatelessWidget {
  const DispatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Global Logi Pro - Dispatch Center')),
      body: const Center(
        child: Text('Màn hình Điều phối Tổng hợp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
