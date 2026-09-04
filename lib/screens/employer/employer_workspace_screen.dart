import 'package:flutter/material.dart';
import 'package:global_logi_pro/core/services/order_service.dart';

class EmployerWorkspaceScreen extends StatefulWidget {
  const EmployerWorkspaceScreen({Key? key}) : super(key: key);
  @override
  State<EmployerWorkspaceScreen> createState() => _EmployerWorkspaceScreenState();
}

class _EmployerWorkspaceScreenState extends State<EmployerWorkspaceScreen> {
  final TextEditingController _pickupCtrl = TextEditingController(text: '123 Nguyễn Huệ, Q.1, TP.HCM');
  final TextEditingController _deliveryCtrl = TextEditingController(text: '45 Lê Duẩn, Q.1, TP.HCM');
  final TextEditingController _weightCtrl = TextEditingController(text: '120');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VogX Employer Workspace'), backgroundColor: Colors.indigo[800]),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Tạo Đơn Hàng Mới Cho Hệ Thống', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 16),
          TextField(controller: _pickupCtrl, decoration: const InputDecoration(labelText: 'Điểm lấy hàng', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _deliveryCtrl, decoration: const InputDecoration(labelText: 'Điểm giao hàng', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Trọng lượng (kg)', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(vertical: 14)),
            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
            label: const Text('Điều Phối Đến Tài Xế', style: TextStyle(color: Colors.white)),
            onPressed: () {
              OrderService().createNewOrder(
                pickup: _pickupCtrl.text,
                delivery: _deliveryCtrl.text,
                weight: '${_weightCtrl.text} kg',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã tạo đơn thành công! Tài xế đã có thể nhận chuyến.')),
              );
            },
          ),
          const SizedBox(height: 20),
          OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Quay lại')),
        ],
      ),
    );
  }
}
