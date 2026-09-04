import 'package:flutter/material.dart';
import 'package:global_logi_pro/core/network/mqtt_service.dart';
import 'package:global_logi_pro/features/dispatches/presentation/dispatch_screen.dart';
import 'package:global_logi_pro/features/driver/presentation/driver_screen.dart';
import 'package:global_logi_pro/features/dispatcher/presentation/dispatcher_screen.dart';

void main() => runApp(const MyApp());

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
  String _connectionStatus = 'Đang kết nối...';
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _initMqtt();
  }

  Future<void> _initMqtt() async {
    try {
      await _mqttService.initializeClient();
      setState(() => _connectionStatus = 'Đã kết nối (Online)');
      _mqttService.onMessageReceived = (topic, message) {
        setState(() => _messages.insert(0, '[$topic] $message'));
      };
    } catch (e) {
      setState(() => _connectionStatus = 'Mất kết nối');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      Scaffold(
        appBar: AppBar(
          title: const Text('☀️ GLOBAL LOGI PRO - LIGHT VIBRANT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF0284C7),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0284C7), width: 3),
                  boxShadow: [BoxShadow(color: const Color(0xFF0284C7).withOpacity(0.3), blurRadius: 15)],
                ),
                child: Text('Trạng thái: $_connectionStatus', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDB2777), width: 2.5),
                  ),
                  child: const Center(
                    child: Text('Đang chờ tín hiệu MQTT trực tuyến...', style: TextStyle(color: Color(0xFF0284C7), fontSize: 16, fontWeight: FontWeight.bold)),
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
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Control'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Driver'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Dispatcher'),
        ],
      ),
    );
  }
}
