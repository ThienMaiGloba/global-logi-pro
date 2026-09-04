import 'package:flutter/material.dart';

void main() {
  runApp(const GlobalLogiProApp());
}

class AppState extends ChangeNotifier {
  final List<OrderModel> orders = [
    OrderModel(id: 'ORD-001', customer: 'Nguyen Van A', route: 'Q.1 -> Q.7', price: 150000, status: 'Mới tạo'),
    OrderModel(id: 'ORD-002', customer: 'Tran Thi B', route: 'Thu Duc -> Binh Thanh', price: 280000, status: 'Đang tìm tài xế'),
  ];

  void updateOrderStatus(String id, String newStatus) {
    final order = orders.firstWhere((o) => o.id == id);
    order.status = newStatus;
    notifyListeners();
  }
}

class OrderModel {
  final String id;
  final String customer;
  final String route;
  final double price;
  String status;

  OrderModel({required this.id, required this.customer, required this.route, required this.price, required this.status});
}

final globalState = AppState();

class GlobalLogiProApp extends StatelessWidget {
  const GlobalLogiProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Logi Pro',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const MainWorkspaceShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainWorkspaceShell extends StatefulWidget {
  const MainWorkspaceShell({super.key});

  @override
  State<MainWorkspaceShell> createState() => _MainWorkspaceShellState();
}

class _MainWorkspaceShellState extends State<MainWorkspaceShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DispatcherScreen(),
    const DriverWorkspaceScreen(),
    const ControlCenterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map), label: 'Dispatcher'),
          NavigationDestination(icon: Icon(Icons.local_shipping), label: 'Driver'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Control'),
        ],
      ),
    );
  }
}

class DispatcherScreen extends StatelessWidget {
  const DispatcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispatcher Live Operations')),
      body: AnimatedBuilder(
        animation: globalState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Text('Danh sách đơn hàng thời gian thực', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              ...globalState.orders.map((o) => Card(
                child: ListTile(
                  title: Text('${o.id} - ${o.customer}'),
                  subtitle: Text('Tuyến: ${o.route} | Cước: ${o.price}đ'),
                  trailing: Chip(
                    label: Text(o.status),
                    backgroundColor: o.status == 'Đã nhận' ? Colors.green[100] : Colors.amber[100],
                  ),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}

class DriverWorkspaceScreen extends StatelessWidget {
  const DriverWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Workspace & Telemetry')),
      body: AnimatedBuilder(
        animation: globalState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              SwitchListTile(
                title: const Text('Trạng thái: Online (Nhận đơn)'),
                value: true,
                activeColor: Colors.green,
                onChanged: (val) {},
              ),
              const Divider(),
              const Text('Đơn hàng chờ nhận', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...globalState.orders.map((o) => Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mã đơn: ${o.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Khách: ${o.customer} (${o.route})'),
                      Text('Thu nhập: ${o.price} VND', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                          onPressed: o.status == 'Đã nhận' ? null : () {
                            globalState.updateOrderStatus(o.id, 'Đã nhận');
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã nhận đơn ${o.id} thành công!')));
                          },
                          icon: const Icon(Icons.check),
                          label: Text(o.status == 'Đã nhận' ? 'Đã nhận' : 'Nhận đơn ngay'),
                        ),
                      )
                    ],
                  ),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}

class ControlCenterScreen extends StatelessWidget {
  const ControlCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control Center & Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Thống kê hệ thống', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(child: ListTile(leading: const Icon(Icons.security, color: Colors.green), title: const Text('Trạng thái API Gateway'), trailing: const Text('Optimal'))),
          Card(child: ListTile(leading: const Icon(Icons.people, color: Colors.blue), title: const Text('Tài xế hoạt động'), trailing: const Text('1'))),
          Card(child: ListTile(leading: const Icon(Icons.shopping_cart, color: Colors.orange), title: const Text('Tổng đơn trong chu kỳ'), trailing: Text('${globalState.orders.length}'))),
        ],
      ),
    );
  }
}
