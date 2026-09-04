import 'package:flutter/material.dart';
import '../driver/driver_workspace_screen.dart';
import '../employer/employer_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  void _login() {
    if (widget.role == 'Driver') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DriverWorkspaceScreen()));
    } else if (widget.role == 'Employer') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EmployerDashboardScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập - ${widget.role}')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email hệ thống', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Mật khẩu bảo mật', border: OutlineInputBorder()), obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text('Xác thực & Truy cập ${widget.role}'),
            ),
          ],
        ),
      ),
    );
  }
}
