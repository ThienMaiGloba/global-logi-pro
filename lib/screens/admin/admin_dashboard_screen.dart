import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Master Control - Giám sát Toàn cầu')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Text('Giám sát Dữ liệu Toàn hệ thống (Realtime DB & GPS)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
          SizedBox(height: 16),
          Card(child: ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('Đơn hàng #9981: Đã hoàn thành POD'), subtitle: Text('Tài xế: Hoàng Thiên Mai | Doanh nghiệp: Logistics Corp'))),
          Card(child: ListTile(leading: Icon(Icons.pending, color: Colors.orange), title: Text('Đơn hàng #9982: Chờ tài xế nhận đơn'), subtitle: Text('Khu vực: Biên Hòa, Đồng Nai'))),
          Card(child: ListTile(leading: Icon(Icons.gps_fixed, color: Colors.blue), title: Text('GPS Tracking Active: 12 tài xế đang trực tuyến'), subtitle: Text('Độ chính xác: Cao (< 5m)'))),
        ],
      ),
    );
  }
}
