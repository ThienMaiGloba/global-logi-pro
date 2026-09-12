import 'package:flutter/material.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/dispatcher_screen.dart';
import 'screens/driver_screen.dart';

void main() {
  runApp(const GlobalLogiApp());
}

class GlobalLogiApp extends StatelessWidget {
  const GlobalLogiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Logi Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginSelectionScreen(),
    );
  }
}

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  final String backendUrl = 'http://192.168.1.42:3000';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 64,
                      color: Colors.blue[800],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Global Logi Pro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    Text(
                      'Hệ thống Quản lý Vận hành & Telemetry',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Chọn phân quyền đăng nhập:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text(
                        'Đăng nhập với vai trò Admin (Quản trị)',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminDashboardScreen(
                              backendUrl: backendUrl,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: const Icon(Icons.support_agent),
                      label: const Text(
                        'Đăng nhập với vai trò Dispatcher (Điều phối)',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DispatcherScreen(
                              backendUrl: backendUrl,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: const Icon(Icons.local_shipping),
                      label: const Text(
                        'Đăng nhập với vai trò Driver (Tài xế)',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DriverScreen(
                              backendUrl: backendUrl,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
