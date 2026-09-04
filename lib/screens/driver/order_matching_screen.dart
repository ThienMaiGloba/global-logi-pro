import 'package:flutter/material.dart';

class OrderMatchingScreen extends StatefulWidget {
  const OrderMatchingScreen({super.key});

  @override
  State<OrderMatchingScreen> createState() => _OrderMatchingScreenState();
}

class _OrderMatchingScreenState extends State<OrderMatchingScreen> {
  String _status = 'Đang tìm kiếm đơn hàng phù hợp...';
  bool _hasOrder = false;
  String _orderTitle = '';
  String _orderState = '';

  void _simulateMatch() {
    setState(() {
      _hasOrder = true;
      _orderTitle = 'Đơn hàng #9981: Cảng Cát Lái → KCN VSIP Bình Dương (Container 40ft)';
      _orderState = 'Đã nhận đơn (Accepted)';
    });
  }

  void _updateStatus(String newState) {
    setState(() => _orderState = newState);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cập nhật trạng thái: $newState')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matching & Điều phối Đơn hàng')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_hasOrder) ...[
              Text(_status, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _simulateMatch,
                child: const Text('Giả lập Nhận đơn hàng Realtime từ Doanh nghiệp'),
              ),
            ] else ...[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_orderTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Trạng thái hiện tại: $_orderState', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => _updateStatus('Đang di chuyển lấy hàng (En Route to Pickup)'), child: const Text('1. Di chuyển lấy hàng')),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () => _updateStatus('Đã nhận hàng / Đang vận chuyển (In Transit)'), child: const Text('2. Đã nhận hàng lên xe')),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () => _updateStatus('Đã giao hàng & Hoàn thành POD (Delivered)'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: const Text('3. Hoàn thành POD & Giao hàng')),
            ],
          ],
        ),
      ),
    );
  }
}
