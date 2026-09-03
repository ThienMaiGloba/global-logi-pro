import 'package:flutter/material.dart';
import 'package:global_logi_pro/core/network/mqtt_service.dart';
import 'package:global_logi_pro/features/driver/presentation/driver_screen.dart';
import 'package:global_logi_pro/features/dispatcher/presentation/dispatcher_screen.dart';
import 'package:global_logi_pro/features/dispatches/presentation/dispatch_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Logi Pro',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainHomeScreen(),
      debugShowCheckedModeBanner: false,
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
  final List<String> _messages = [];

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
              Text('Trạng thái hệ thống: $_connectionStatus', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              const Text('Tin nhắn thực tế từ Broker (Realtime):', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _messages.isEmpty
                      ? const Text('Chưa có tin nhắn nào từ broker', style: TextStyle(color: Colors.grey))
                      : ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) => Text(_messages[index]),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      const DriverScreen(),
      const DispatcherScreen(),
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
