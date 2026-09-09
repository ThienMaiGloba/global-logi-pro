import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:http/http.dart' as http;
import 'dart:convert';
=======
>>>>>>> 4f4dee3efa65b4e34943f620df3f1d97dceed81b

class DispatcherScreen extends StatefulWidget {
  final String backendUrl;
  const DispatcherScreen({super.key, required this.backendUrl});

  @override
  State<DispatcherScreen> createState() => _DispatcherScreenState();
}

class _DispatcherScreenState extends State<DispatcherScreen> {
<<<<<<< HEAD
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
=======
  final _pickupController = TextEditingController(text: 'Quận 1, TP.HCM');
  final _dropoffController = TextEditingController(text: 'Quận 7, TP.HCM');
  final _customerController = TextEditingController(text: 'Nguyễn Văn A');
  final _priceController = TextEditingController(text: '45000');
  List<Map<String, dynamic>> orders = [
    {'id': '#LOG-101', 'pickup': 'Quận 1', 'dropoff': 'Quận 3', 'status': 'Chờ nhận đơn', 'driver': 'Chưa gán'},
    {'id': '#LOG-102', 'pickup': 'Quận 5', 'dropoff': 'Quận 10', 'status': 'Đang giao', 'driver': 'Tài xế Trần B'}
  ];

  void _createOrder() {
    setState(() {
      orders.insert(0, {
        'id': '#LOG-${100 + orders.length + 1}',
        'pickup': _pickupController.text,
        'dropoff': _dropoffController.text,
        'status': 'Chờ nhận đơn',
        'driver': 'Chưa gán'
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo đơn hàng thành công!')));
>>>>>>> 4f4dee3efa65b4e34943f620df3f1d97dceed81b
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
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
=======
        title: const Text('Dispatcher - Điều phối đơn hàng'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tạo đơn hàng mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _pickupController, decoration: const InputDecoration(labelText: 'Điểm lấy hàng', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: _dropoffController, decoration: const InputDecoration(labelText: 'Điểm giao hàng', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: _customerController, decoration: const InputDecoration(labelText: 'Khách hàng', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Giá tiền (VNĐ)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _createOrder,
              icon: const Icon(Icons.add),
              label: const Text('Tạo & Đẩy đơn lên hệ thống'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], minimumSize: const Size(double.infinity, 48)),
            ),
            const SizedBox(height: 24),
            const Text('Danh sách đơn hàng điều phối', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.local_shipping, color: Colors.blue),
                      title: Text('${order['id']} - ${order['pickup']} → ${order['dropoff']}'),
                      subtitle: Text('Trạng thái: ${order['status']} | Tài xế: ${order['driver']}'),
                      trailing: ElevatedButton(
                        child: const Text('Gán tài xế'),
                        onPressed: () {
                          setState(() {
                            order['driver'] = 'Tài xế Lê C';
                            order['status'] = 'Đã gán tài xế';
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
>>>>>>> 4f4dee3efa65b4e34943f620df3f1d97dceed81b
    );
  }
}
