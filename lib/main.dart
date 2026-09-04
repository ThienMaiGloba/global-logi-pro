import "package:global_logi_pro/features/dispatches/presentation/dispatch_screen.dart";
import 'package:flutter/material.dart';
import 'package:global_logi_pro/core/network/mqtt_service.dart';
import 'package:global_logi_pro/features/driver/presentation/driver_screen.dart';
import 'package:global_logi_pro/features/dispatcher/presentation/dispatcher_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Logi Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0284C7)),
      ),
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
        appBar: AppBar(
          title: const Text('Global Logi Pro - Control Center', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF0284C7),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0284C7), width: 2),
                ),
                child: Text('Trạng thái: $_connectionStatus', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
              ),
              const SizedBox(height: 20),
              const Text('Tin nhắn nhận được từ hệ thống:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
              const SizedBox(height: 10),
              const Expanded(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('Chưa có tin nhắn nào', style: TextStyle(color: Color(0xFF64748B)))),
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
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0284C7),
        unselectedItemColor: const Color(0xFF64748B),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Control'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Driver'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Dispatcher'),
        ],
      ),
    );
  }
}
