import 'package:flutter/material.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  final List<String> _orders = ['Đơn #9981: Cảng Cát Lái → Bình Dương (Đang vận chuyển)'];

  void _createNewOrder() {
    setState(() {
      _orders.add('Đơn #9982: Tân Sơn Nhất → Biên Hòa (Mới tạo)');
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã tạo đơn hàng thành công và phát sóng hệ thống!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employer Portal - Quản lý Vận chuyển')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _createNewOrder,
              icon: const Icon(Icons.add),
              label: const Text('Tạo đơn vận chuyển mới'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            const SizedBox(height: 20),
            const Text('Danh sách đơn hàng thực tế:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) => Card(child: ListTile(title: Text(_orders[index]), trailing: const Icon(Icons.local_shipping, color: Colors.blue))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
