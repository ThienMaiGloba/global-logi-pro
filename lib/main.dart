import 'package:flutter/material.dart';

void main() {
  runApp(const GlobalLogiProApp());
}

class AppState extends ChangeNotifier {
  final List<OrderModel> orders = [
    OrderModel(id: 'ORD-001', customer: 'Công ty Alpha', route: 'Quận 1 -> Quận 7', price: 150000, status: 'Mới tạo', driver: 'Chưa gán'),
    OrderModel(id: 'ORD-002', customer: 'Kho Logistics Beta', route: 'Thủ Đức -> Bình Thạnh', price: 280000, status: 'Mới tạo', driver: 'Chưa gán'),
  ];

  final List<DriverModel> drivers = [
    DriverModel(id: 'D1', name: 'Trần Văn Tài', status: 'Online', currentOrder: 'Không có'),
    DriverModel(id: 'D2', name: 'Nguyễn Văn Hùng', status: 'Online', currentOrder: 'Không có'),
  ];

  final List<String> activityLogs = [
    'Hệ thống khởi động thành công.',
    'Đã khởi tạo đơn hàng ORD-001 và ORD-002.'
  ];

  void logActivity(String message) {
    final now = DateTime.now();
    activityLogs.insert(0, '[${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}] $message');
    notifyListeners();
  }

  void updateOrderStatus(String id, String newStatus, {String? driverName}) {
    final order = orders.firstWhere((o) => o.id == id);
    order.status = newStatus;
    if (driverName != null) order.driver = driverName;
    logActivity('Đơn hàng $id chuyển trạng thái: $newStatus (Tài xế: ${order.driver})');
    notifyListeners();
  }

  void addOrder(OrderModel newOrder) {
    orders.add(newOrder);
    logActivity('Đã tạo đơn mới: ${newOrder.id} - ${newOrder.customer}');
    notifyListeners();
  }
}

class OrderModel {
  final String id;
  final String customer;
  final String route;
  final double price;
  String status;
  String driver;

  OrderModel({required this.id, required this.customer, required this.route, required this.price, required this.status, required this.driver});
}

class DriverModel {
  final String id;
  final String name;
  String status;
  String currentOrder;

  DriverModel({required this.id, required this.name, required this.status, required this.currentOrder});
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
          NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Control & Logs'),
        ],
      ),
    );
  }
}

class DispatcherScreen extends StatefulWidget {
  const DispatcherScreen({super.key});

  @override
  State<DispatcherScreen> createState() => _DispatcherScreenState();
}

class _DispatcherScreenState extends State<DispatcherScreen> {
  String _filter = 'Tất cả';

  void _showCreateOrderDialog(BuildContext context) {
    final idController = TextEditingController(text: 'ORD-00${globalState.orders.length + 1}');
    final customerController = TextEditingController();
    final routeController = TextEditingController();
    final priceController = TextEditingController(text: '200000');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo đơn hàng mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã đơn')),
            TextField(controller: customerController, decoration: const InputDecoration(labelText: 'Tên khách hàng')),
            TextField(controller: routeController, decoration: const InputDecoration(labelText: 'Tuyến đường (A -> B)')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Giá cước (VND)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (customerController.text.isNotEmpty && routeController.text.isNotEmpty) {
                globalState.addOrder(OrderModel(
                  id: idController.text,
                  customer: customerController.text,
                  route: routeController.text,
                  price: double.tryParse(priceController.text) ?? 150000,
                  status: 'Mới tạo',
                  driver: 'Chưa gán',
                ));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo đơn hàng thành công!')));
              }
            },
            child: const Text('Tạo đơn'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatcher Live Operations'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButton<String>(
              value: _filter,
              items: ['Tất cả', 'Mới tạo', 'Đã nhận', 'Hoàn thành'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
              onChanged: (val) => setState(() => _filter = val!),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: globalState,
        builder: (context, _) {
          final displayedOrders = _filter == 'Tất cả' 
              ? globalState.orders 
              : globalState.orders.where((o) => o.status == _filter).toList();

          return Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.blueGrey[50],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.radar, size: 64, color: Colors.indigo),
                      const SizedBox(height: 12),
                      const Text('Bản đồ điều phối thời gian thực', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Tổng đơn: ${globalState.orders.length} | Tài xế trực tuyến: ${globalState.drivers.length}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    Text('Danh sách đơn hàng (${displayedOrders.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    ...displayedOrders.map((o) => Card(
                      child: ListTile(
                        title: Text('${o.id} - ${o.customer}'),
                        subtitle: Text('Tuyến: ${o.route}\nTài xế: ${o.driver} | ${o.price.toInt()}đ'),
                        isThreeLine: true,
                        trailing: Chip(
                          label: Text(o.status),
                          backgroundColor: o.status == 'Đã nhận' 
                              ? Colors.green[100] 
                              : (o.status == 'Hoàn thành' ? Colors.blue[100] : Colors.amber[100]),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOrderDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Tạo đơn mới'),
      ),
    );
  }
}

class DriverWorkspaceScreen extends StatefulWidget {
  const DriverWorkspaceScreen({super.key});

  @override
  State<DriverWorkspaceScreen> createState() => _DriverWorkspaceScreenState();
}

class _DriverWorkspaceScreenState extends State<DriverWorkspaceScreen> {
  bool isOnline = true;

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
                title: Text('Trạng thái tài xế: ${isOnline ? "Online (Sẵn sàng)" : "Offline"}'),
                value: isOnline,
                activeColor: Colors.green,
                onChanged: (val) => setState(() => isOnline = val),
              ),
              const Divider(),
              const Text('Nhiệm vụ vận chuyển', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...globalState.orders.map((o) => Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mã đơn: ${o.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Chip(
                            label: Text(o.status),
                            backgroundColor: o.status == 'Đã nhận' 
                                ? Colors.green[100] 
                                : (o.status == 'Hoàn thành' ? Colors.blue[100] : Colors.amber[100]),
                          ),
                        ],
                      ),
                      Text('Khách: ${o.customer} (${o.route})'),
                      Text('Thu nhập: ${o.price.toInt()} VND', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (o.status == 'Đã nhận') ...[
                            OutlinedButton.icon(
                              onPressed: () {
                                globalState.updateOrderStatus(o.id, 'Hoàn thành', driverName: 'Trần Văn Tài');
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hoàn thành đơn hàng!')));
                              },
                              icon: const Icon(Icons.done_all, color: Colors.blue),
                              label: const Text('Hoàn thành'),
                            ),
                            const SizedBox(width: 8),
                          ],
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: o.status == 'Đã nhận' ? Colors.red[700] : Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              if (!isOnline) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bạn cần bật Online để nhận đơn!')));
                                return;
                              }
                              final nextStatus = o.status == 'Đã nhận' ? 'Mới tạo' : 'Đã nhận';
                              final driverName = nextStatus == 'Đã nhận' ? 'Trần Văn Tài' : 'Chưa gán';
                              globalState.updateOrderStatus(o.id, nextStatus, driverName: driverName);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã cập nhật trạng thái đơn ${o.id}!'))
                              );
                            },
                            icon: Icon(o.status == 'Đã nhận' ? Icons.close : Icons.check),
                            label: Text(o.status == 'Đã nhận' ? 'Hủy nhận' : 'Nhận đơn ngay'),
                          ),
                        ],
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
      appBar: AppBar(title: const Text('Control Center & Audit Logs')),
      body: AnimatedBuilder(
        animation: globalState,
        builder: (context, _) {
          final totalRevenue = globalState.orders
              .where((o) => o.status == 'Hoàn thành' || o.status == 'Đã nhận')
              .fold(0.0, (sum, o) => sum + o.price);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Chỉ số vận hành hệ thống', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _StatCard(title: 'Tổng đơn', value: '${globalState.orders.length}', icon: Icons.shopping_cart, color: Colors.orange)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(title: 'Tài xế Online', value: '${globalState.drivers.length}', icon: Icons.people, color: Colors.blue)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(title: 'Doanh thu', value: '${totalRevenue.toInt()}đ', icon: Icons.attach_money, color: Colors.green)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Nhật ký kiểm toán thời gian thực (Audit Logs)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: globalState.activityLogs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        globalState.activityLogs[index],
                        style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 13),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
