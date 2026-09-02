import 'package:flutter/material.dart';

class DriverScreen extends StatelessWidget {
  const DriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Portal - Fleet & Active Trips'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Trạng thái hoạt động:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Switch(
                      value: true,
                      onChanged: (val) {},
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Đơn hàng chờ nhận (Dispatch Offers):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: const [
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.local_shipping, color: Colors.indigo),
                      title: Text('Đơn hàng #LOGI-8821'),
                      subtitle: Text('Lấy: Quận 1, TP.HCM -> Giao: Thủ Đức\nLoại xe: Xe tải 1.5 Tấn'),
                      trailing: ElevatedButton(
                        onPressed: null,
                        child: Text('Nhận đơn'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
