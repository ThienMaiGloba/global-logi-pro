import 'package:flutter/material.dart';
import 'package:global_logi_pro/core/network/mqtt_service.dart';
import 'package:global_logi_pro/features/dispatches/presentation/dispatch_screen.dart';
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
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
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

      _mqttService.onMessageReceived = (topic, message) {
        setState(() {
          _messages.insert(0, '[$topic] $message');
        });
      };
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
              const SizedBox(height: 8),
              Expanded(
                child: _messages.isEmpty
                    ? const Card(child: Center(child: Padding(padding: EdgeInsets.all(12.0), child: Text('Chưa có tin nhắn nào'))))
                    : ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(_messages[index]),
                            ),
                          );
                        },
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
