import 'package:flutter/material.dart';
import '../models/vehicle_category.dart';
import 'order_dispatch_screen.dart';

class FleetManagementScreen extends StatelessWidget {
  const FleetManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Logi Pro - Hệ Thống Phương Tiện'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: globalLogiFleetList.length,
        itemBuilder: (context, index) {
          final cat = globalLogiFleetList[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text('${index + 1}', style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('Tải trọng:', cat.payload),
                  const SizedBox(height: 6),
                  _buildInfoRow('Khu vực:', cat.operatingArea),
                  const SizedBox(height: 6),
                  _buildInfoRow('Giải pháp:', cat.solution),
                  const SizedBox(height: 12),
                  const Text('Các dòng xe:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: cat.examples.map((ex) => Chip(
                      label: Text(ex, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.grey.shade100,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDispatchScreen(vehicleCategory: cat),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text('Chọn xe & Tạo đơn điều phối'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
      ],
    );
  }
}
