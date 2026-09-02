import 'package:flutter/material.dart';
import 'package:global_logi_pro/core/network/mqtt_service.dart';
import 'package:global_logi_pro/features/driver/presentation/driver_screen.dart';

void main() {
  runApp(const GlobalLogiProApp());
}

class GlobalLogiProApp extends StatelessWidget {
  const GlobalLogiProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Logi Pro',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  final MqttService _mqttService = MqttService();
  String _connectionStatus = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _initMqtt();
  }

  Future<void> _initMqtt() async {
    try {
      await _mqttService.initializeClient();
      setState(() {
        _connectionStatus = 'Connected (Online)';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection Failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      Scaffold(
        appBar: AppBar(title: const Text('Global Logi Pro - Control Center')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Trạng thái: $_connectionStatus', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              const Text('Tin nhắn nhận được từ hệ thống:'),
              const Card(child: Padding(padding: EdgeInsets.all(12.0), child: Text('Chưa có tin nhắn nào'))),
            ],
          ),
        ),
      ),
      const DriverScreen(),
      const Scaffold(
        body: Center(child: Text('Dispatcher Console: Live Map & Fleet Routing', style: TextStyle(fontSize: 18))),
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Control'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Driver'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Dispatcher'),
        ],
      ),
    );
  }
}
