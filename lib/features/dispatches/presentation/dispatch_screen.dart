import 'package:flutter/material.dart';

class DispatchScreen extends StatelessWidget {
  const DispatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispatch Management')),
      body: const Center(child: Text('Live Dispatch Console - Production Ready')),
    );
  }
}
