import 'package:flutter/material.dart';

class AdminWorkspaceScreen extends StatelessWidget {
  const AdminWorkspaceScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VogX Admin Control'), backgroundColor: Colors.red[900]),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Bảng điều khiển hệ thống', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 16),
          const Card(child: ListTile(title: Text('Tổng đơn hàng hôm nay'), trailing: Text('1,482', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)))),
          const Card(child: ListTile(title: Text('Tài xế đang hoạt động'), trailing: Text('312', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)))),
          const SizedBox(height: 20),
          OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Quay lại')),
        ],
      ),
    );
  }
}
