import 'package:flutter/material.dart';

class DispatcherScreen extends StatefulWidget {
  final String backendUrl;
  const DispatcherScreen({super.key, required this.backendUrl});

  @override
  State<DispatcherScreen> createState() => _DispatcherScreenState();
}

class _DispatcherScreenState extends State<DispatcherScreen> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
    );
  }
}
