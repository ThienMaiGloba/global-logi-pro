import 'package:flutter/material.dart';

class DispatcherScreen extends StatelessWidget {
  const DispatcherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatcher Dashboard'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Điều phối vận chuyển',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Text('Danh sách điều phối đang trống.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
