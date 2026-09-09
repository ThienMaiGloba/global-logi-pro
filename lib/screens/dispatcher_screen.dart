import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DispatcherScreen extends StatefulWidget {
  final String backendUrl;
  const DispatcherScreen({super.key, required this.backendUrl});

  @override
  State<DispatcherScreen> createState() => _DispatcherScreenState();
}

class _DispatcherScreenState extends State<DispatcherScreen> {
  List<dynamic> activeOrders = [
    {'id': 'ORD-001', 'driver': 'Nguyễn Văn A', 'status': 'Đang giao hàng', 'route': 'Q.1 -> Q.7'},
    {'id': 'ORD-002', 'driver': 'Trần Văn B', 'status': 'Đã nhận đơn', 'route': 'Thủ Đức -> Bình Thạnh'},
    {'id': 'ORD-003', 'driver': 'Lê Văn C', 'status': 'Hoàn thành', 'route': 'Q.3 -> Tân Bình'},
  ];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('${widget.backendUrl}/dispatcher/orders'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            activeOrders = data;
          });
        }
      }
    } catch (e) {
      // Dùng dữ liệu mẫu nếu mất kết nối backend
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatcher Control Center'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchOrders,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: [
                  const Text(
                    'Điều phối & Giám sát lộ trình',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.map, color: Colors.blue, size: 18),
                              SizedBox(width: 6),
                              Text('Bản đồ Telemetry Trực tuyến', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 90,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.satellite_alt, size: 28, color: Colors.blue),
                                  SizedBox(height: 2),
                                  Text('Đang kết nối GPS Fleet Tracking...', style: TextStyle(color: Colors.blueGrey, fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Danh sách đơn hàng cần điều phối',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...activeOrders.map((order) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.local_shipping, color: Colors.blue, size: 22),
                          title: Text('${order['id']} - ${order['driver']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('Lộ trình: ${order['route']} | Trạng thái: ${order['status']}', style: const TextStyle(fontSize: 11)),
                          trailing: IconButton(
                            icon: const Icon(Icons.navigation, color: Colors.orange, size: 18),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Mở điều hướng cho đơn ${order['id']}'))
                              );
                            },
                          ),
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}
