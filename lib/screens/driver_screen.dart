import 'package:flutter/material.dart';

<<<<<<< HEAD
class DriverScreen extends StatelessWidget {
  final String? backendUrl;

  const DriverScreen({super.key, this.backendUrl});
=======
class DriverScreen extends StatefulWidget {
  final String backendUrl;
  const DriverScreen({super.key, required this.backendUrl});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  List<Map<String, dynamic>> assignedOrders = [
    {'id': '#LOG-101', 'pickup': 'Quận 1', 'dropoff': 'Quận 3', 'price': '45,000 đ', 'status': 'Chờ nhận'},
    {'id': '#LOG-103', 'pickup': 'Bình Thạnh', 'dropoff': 'Thủ Đức', 'price': '65,000 đ', 'status': 'Đang giao'}
  ];
>>>>>>> 4f4dee3efa65b4e34943f620df3f1d97dceed81b

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('Global Logi Pro - Driver'),
        backgroundColor: Colors.blueAccent,
=======
        title: const Text('Driver - Tài xế nhận đơn'),
        backgroundColor: Colors.green[700],
>>>>>>> 4f4dee3efa65b4e34943f620df3f1d97dceed81b
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
<<<<<<< HEAD
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chuyến đi hiện tại: #GLP-8824',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Điểm đi: Kho Tổng Tân Bình'),
                    Text('Điểm đến: Cảng Cát Lái, Quận 2'),
                    Text('Trạng thái: Đang vận chuyển'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xác nhận hoàn thành chuyến đi!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                'Xác nhận hoàn thành',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
=======
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Đơn hàng của bạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Chip(label: Text('Trạng thái: Sẵn sàng nhận đơn', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: assignedOrders.length,
                itemBuilder: (context, index) {
                  final order = assignedOrders[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(order['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(order['price'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800], fontSize: 16)),
                            ],
                          ),
                          const Divider(),
                          Text('📍 Lấy: ${order['pickup']}'),
                          Text('🏁 Giao: ${order['dropoff']}'),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Trạng thái: ${order['status']}', style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () {
                                  setState(() {
                                    order['status'] = 'Đã hoàn thành';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật trạng thái thành công!')));
                                },
                                child: const Text('Cập nhật trạng thái'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
>>>>>>> 4f4dee3efa65b4e34943f620df3f1d97dceed81b
          ],
        ),
      ),
    );
  }
}
