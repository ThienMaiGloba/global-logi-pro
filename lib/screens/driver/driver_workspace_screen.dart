import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:global_logi_pro/core/utils/navigation_provider.dart';
import 'package:global_logi_pro/core/services/order_service.dart';

class DriverWorkspaceScreen extends StatefulWidget {
  const DriverWorkspaceScreen({Key? key}) : super(key: key);
  @override
  State<DriverWorkspaceScreen> createState() => _DriverWorkspaceScreenState();
}

class _DriverWorkspaceScreenState extends State<DriverWorkspaceScreen> {
  File? _pickupProof;
  File? _deliveryProof;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _otpController = TextEditingController();

  Future<void> _takeProof(bool isPickup) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      setState(() {
        if (isPickup) {
          _pickupProof = File(image.path);
          OrderService().orderStatus = 'DELIVERY_NAVIGATING';
        } else {
          _deliveryProof = File(image.path);
          OrderService().orderStatus = 'COMPLETED';
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isPickup ? 'Đã lưu Proof of Pickup!' : 'Đã giao hàng thành công!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = OrderService();
    return Scaffold(
      appBar: AppBar(title: const Text('VogX Driver Workspace'), backgroundColor: Colors.blue[800]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trạng thái: ${order.orderStatus}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text('Mã đơn hàng: ${order.trackingId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Trọng lượng: ${order.orderWeight}'),
                    const Divider(height: 20),
                    if (order.orderStatus.contains('PICKUP')) ...[
                      const Text('📍 Điểm Lấy Hàng:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text(order.pickupLocation),
                    ] else if (order.orderStatus.contains('DELIVERY')) ...[
                      const Text('🏁 Điểm Giao Hàng:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      Text(order.deliveryLocation),
                    ] else ...[
                      const Text('🎉 Đơn hàng đã hoàn tất giao dịch!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (order.orderStatus != 'COMPLETED')
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: order.orderStatus.contains('PICKUP') ? Colors.blue : Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.navigation, color: Colors.white),
                label: Text(
                  order.orderStatus.contains('PICKUP') ? 'Mở bản đồ đến điểm LẤY HÀNG' : 'Mở bản đồ đến điểm GIAO HÀNG',
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  bool isPickup = order.orderStatus.contains('PICKUP');
                  await NavigationProvider.openNavigation(
                    lat: isPickup ? 10.7769 : 10.7825,
                    lng: isPickup ? 106.7009 : 106.6983,
                    label: isPickup ? order.pickupLocation : order.deliveryLocation,
                  );
                },
              ),
            const SizedBox(height: 12),
            if (order.orderStatus == 'PICKUP_NAVIGATING')
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('Chụp Proof of Pickup', style: TextStyle(color: Colors.white)),
                onPressed: () => _takeProof(true),
              ),
            if (order.orderStatus == 'DELIVERY_NAVIGATING') ...[
              const SizedBox(height: 10),
              TextField(controller: _otpController, decoration: const InputDecoration(labelText: 'Mã OTP nhận hàng', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: const Icon(Icons.verified, color: Colors.white),
                label: const Text('Chụp Proof of Delivery & Hoàn thành', style: TextStyle(color: Colors.white)),
                onPressed: () => _takeProof(false),
              ),
            ],
            const SizedBox(height: 20),
            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Quay lại màn hình chính')),
          ],
        ),
      ),
    );
  }
}
