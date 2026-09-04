import 'package:flutter/material.dart';
import '../models/vehicle_category.dart';

class OrderDispatchScreen extends StatefulWidget {
  final VehicleCategory vehicleCategory;

  const OrderDispatchScreen({Key? key, required this.vehicleCategory}) : super(key: key);

  @override
  State<OrderDispatchScreen> createState() => _OrderDispatchScreenState();
}

class _OrderDispatchScreenState extends State<OrderDispatchScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitOrder(BuildContext context) {
    if (_pickupController.text.isEmpty || _dropoffController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ điểm lấy và giao hàng!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 Điều Phố Thành Công'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loại xe: ${widget.vehicleCategory.name}'),
            const SizedBox(height: 8),
            Text('Tải trọng: ${widget.vehicleCategory.payload}'),
            const SizedBox(height: 8),
            Text('Lấy hàng: ${_pickupController.text}'),
            const SizedBox(height: 8),
            Text('Giao hàng: ${_dropoffController.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Đóng Dialog
              Navigator.pop(context); // Về màn hình danh sách xe
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Đơn Hàng Điều Phối'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Phương tiện đã chọn:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(widget.vehicleCategory.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Tải trọng chuẩn: ${widget.vehicleCategory.payload}'),
                    Text('Giải pháp: ${widget.vehicleCategory.solution}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pickupController,
              decoration: const InputDecoration(
                labelText: 'Địa điểm lấy hàng (Pickup)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dropoffController,
              decoration: const InputDecoration(
                labelText: 'Địa điểm giao hàng (Drop-off)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag, color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Ghi chú hàng hóa',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.white,
              ),
              onPressed: () => _submitOrder(context),
              icon: const Icon(Icons.local_shipping),
              label: const Text('Xác Nhận Tạo Đơn & Điều Phối', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
