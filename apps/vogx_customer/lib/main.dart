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
      title: 'VOGX Customer',
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
  final api = ApiClient('http://10.0.2.2:3000');
  String status = 'VOGX Customer sẵn sàng';

  Future<void> checkBackend() async {
    try {
      final result = await api.get('/health');
      setState(() => status = 'Backend: $result');
    } catch (e) {
      setState(() => status = 'Backend chưa kết nối: $e');
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
      status = ok ? 'Đã mở ứng dụng bản đồ' : 'Không mở được ứng dụng bản đồ';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VOGX Customer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.local_shipping, size: 72),
          const SizedBox(height: 16),
          Text(
            'VOGX Customer',
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
            onPressed: locate,
            icon: const Icon(Icons.my_location),
            label: const Text('Lấy GPS thật'),
          ),
          FilledButton.icon(
            onPressed: openNavigation,
            icon: const Icon(Icons.navigation),
            label: const Text('Mở ứng dụng bản đồ điện thoại'),
          ),
        ],
      ),
    );
  }
}
