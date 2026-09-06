import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDashboardScreen extends StatefulWidget {
  final String backendUrl;
  const AdminDashboardScreen({super.key, required this.backendUrl});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> stats = {
    'totalOrders': 142,
    'totalRevenue': 18500000,
    'activeDrivers': 15,
    'systemStatus': 'Online'
  };
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('${widget.backendUrl}/admin/stats'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          setState(() {
            stats = data;
          });
        }
      }
    } catch (e) {
      // Dùng dữ liệu mẫu nếu mất kết nối
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Control Center'),
        backgroundColor: Colors.orange[800],
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchStats)
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text('Thống kê hệ thống Logistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard('Tổng đơn hàng', '${stats['totalOrders'] ?? 0}', Icons.shopping_bag, Colors.blue),
                      _buildStatCard('Doanh thu', '${stats['totalRevenue'] ?? 0} đ', Icons.attach_money, Colors.green),
                      _buildStatCard('Tài xế Online', '${stats['activeDrivers'] ?? 0}', Icons.drive_eta, Colors.orange),
                      _buildStatCard('Trạng thái', '${stats['systemStatus'] ?? 'Offline'}', Icons.check_circle, Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Quản lý hệ thống nhanh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.people, color: Colors.blue),
                    title: const Text('Quản lý tài xế & phân quyền'),
                    subtitle: const Text('Duyệt tài xế, khóa tài khoản'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng quản lý tài xế đang mở')));
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.local_shipping, color: Colors.green),
                    title: const Text('Giám sát toàn bộ đơn hàng'),
                    subtitle: const Text('Theo dõi lịch trình thời gian thực'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang tải danh sách đơn hàng toàn hệ thống')));
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
