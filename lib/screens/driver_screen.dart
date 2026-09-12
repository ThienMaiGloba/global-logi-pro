import 'package:flutter/material.dart';

class DriverScreen extends StatelessWidget {
  final String backendUrl;

  const DriverScreen({super.key, required this.backendUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Danh sách nhiệm vụ vận chuyển',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Text('Chưa có nhiệm vụ mới được phân công.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
