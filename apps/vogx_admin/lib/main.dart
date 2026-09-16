import 'package:flutter/material.dart';
import 'package:vogx_core/vogx_core.dart';

void main() {
  runApp(const VogxApp());
}

class VogxApp extends StatelessWidget {
  const VogxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VOGX Admin / Dispatcher',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final api = ApiClient('http://192.168.1.42:3000');

  String status = 'VOGX Admin / Dispatcher sẵn sàng';
  bool loadingOrders = false;
  List<Order> orders = [];

  Future<void> checkBackend() async {
    try {
      final result = await api.get('/api/health');
      if (!mounted) return;
      setState(() => status = 'Backend: $result');
    } catch (e) {
      if (!mounted) return;
      setState(() => status = 'Backend chưa kết nối: $e');
    }
  }

  Future<void> loadOrders() async {
    if (loadingOrders) return;

    setState(() {
      loadingOrders = true;
      status = 'Đang tải Order thật...';
    });

    try {
      final result = await api.get('/api/orders');

      final loadedOrders = (result as List)
          .map((item) => Order.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();

      if (!mounted) return;

      setState(() {
        orders = loadedOrders;
        loadingOrders = false;
        status = 'Đã tải ${orders.length} Order thật từ Backend';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingOrders = false;
        status = 'Tải Order lỗi: $e';
      });
    }
  }

  Future<void> locate() async {
    final position = await LocationService.current();

    if (!mounted) return;

    setState(() {
      status = position == null
          ? 'Không lấy được GPS'
          : 'GPS: ${position.latitude}, ${position.longitude}';
    });
  }

  Future<void> openNavigation() async {
    final ok = await NavigationService.navigateTo(
      latitude: 10.7769,
      longitude: 106.7009,
      label: 'VOGX Demo Destination',
    );

    if (!mounted) return;

    setState(() {
      status = ok
          ? 'Đã mở ứng dụng bản đồ'
          : 'Không mở được ứng dụng bản đồ';
    });
  }

  String money(int value) {
    return '${value.toString().replaceAllMapped(
          RegExp(r'(\\d)(?=(\\d{3})+(?!\\d))'),
          (m) => '${m[1]},',
        )} VND';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VOGX Admin / Dispatcher'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.local_shipping, size: 72),
          const SizedBox(height: 16),
          Text(
            'VOGX Admin / Dispatcher',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(status),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: checkBackend,
            icon: const Icon(Icons.cloud),
            label: const Text('Kiểm tra Backend'),
          ),
          FilledButton.icon(
            onPressed: loadingOrders ? null : loadOrders,
            icon: loadingOrders
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.receipt_long),
            label: Text(
              loadingOrders ? 'Đang tải Order...' : 'Tải Order thật',
            ),
          ),
          FilledButton.icon(
            onPressed: locate,
            icon: const Icon(Icons.my_location),
            label: const Text('Lấy GPS thật'),
          ),
          FilledButton.icon(
            onPressed: openNavigation,
            icon: const Icon(Icons.navigation),
            label: const Text('Mở ứng dụng bản đồ điện thoại'),
          ),
          const SizedBox(height: 24),
          Text(
            'ORDERS THẬT',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Chưa tải Order.'),
              ),
            ),
          ...orders.map(
            (order) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${order.id}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Status: ${order.status.name.toUpperCase()}'),
                    Text('Giá: ${money(order.price)}'),
                    Text('Customer: ${order.customerId}'),
                    const SizedBox(height: 12),
                    ...order.stops.map(
                      (stop) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${stop.sequence}. ${stop.type.toUpperCase()} — '
                          '${stop.address} '
                          '(${stop.latitude}, ${stop.longitude})',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
