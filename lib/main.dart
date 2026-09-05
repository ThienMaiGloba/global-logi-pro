import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await globalState.initDB();
  runApp(const GlobalLogiProApp());
}

class AppState extends ChangeNotifier {
  Database? _db;
  List<OrderModel> orders = [];
  bool isOnline = true;
  String searchQuery = '';
  String filterStatus = 'Tất cả';

  // Role: 'Dispatcher', 'Driver', 'Admin'
  String? currentRole;

  // GPS Telemetry State
  double driverLat = 10.7769;
  double driverLng = 106.7009;
  double driverSpeed = 0.0;
  Timer? _gpsTimer;

  Future<void> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'global_logi_pro_v2.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE orders(
            id TEXT PRIMARY KEY,
            customer TEXT,
            route TEXT,
            price REAL,
            status TEXT
          )
        ''');
        await db.insert('orders', {'id': 'ORD-001', 'customer': 'Nguyen Van A', 'route': 'Q.1 -> Q.7', 'price': 150000.0, 'status': 'Mới tạo'});
        await db.insert('orders', {'id': 'ORD-002', 'customer': 'Tran Thi B', 'route': 'Thu Duc -> Binh Thanh', 'price': 280000.0, 'status': 'Đang tìm tài xế'});
        await db.insert('orders', {'id': 'ORD-003', 'customer': 'Le Van C', 'route': 'Tan Binh -> Go Vap', 'price': 220000.0, 'status': 'Đã nhận'});
      },
    );
    await fetchOrders();
  }

  Future<void> fetchOrders() async {
    if (_db == null) return;
    final maps = await _db!.query('orders');
    orders = maps.map((m) => OrderModel.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> updateOrderStatus(String id, String newStatus) async {
    if (_db == null) return;
    await _db!.update(
      'orders',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchOrders();
  }

  void login(String role) {
    currentRole = role;
    notifyListeners();
  }

  void logout() {
    currentRole = null;
    stopGpsSimulation();
    notifyListeners();
  }

  void setSearchQuery(String q) {
    searchQuery = q;
    notifyListeners();
  }

  void setFilterStatus(String status) {
    filterStatus = status;
    notifyListeners();
  }

  List<OrderModel> get filteredOrders {
    return orders.where((o) {
      final matchesSearch = o.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
          o.customer.toLowerCase().contains(searchQuery.toLowerCase()) ||
          o.route.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter = filterStatus == 'Tất cả' || o.status == filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void toggleDriverStatus(bool val) {
    isOnline = val;
    if (isOnline) {
      startGpsSimulation();
    } else {
      stopGpsSimulation();
    }
    notifyListeners();
  }

  void startGpsSimulation() {
    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // Giả lập tọa độ thay đổi nhẹ quanh TP.HCM
      driverLat += 0.0005;
      driverLng += 0.0003;
      driverSpeed = 35.5 + (DateTime.now().second % 10);
      notifyListeners();
    });
  }

  void stopGpsSimulation() {
    _gpsTimer?.cancel();
    driverSpeed = 0.0;
  }
}

class OrderModel {
  final String id;
  final String customer;
  final String route;
  final double price;
  String status;

  OrderModel({required this.id, required this.customer, required this.route, required this.price, required this.status});

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      customer: map['customer'],
      route: map['route'],
      price: map['price'],
      status: map['status'],
    );
  }
}

final globalState = AppState();

class GlobalLogiProApp extends StatelessWidget {
  const GlobalLogiProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Logi Pro',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: AnimatedBuilder(
        animation: globalState,
        builder: (context, _) {
          if (globalState.currentRole == null) {
            return const LoginScreen();
          }
          return const MainWorkspaceShell();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_shipping, size: 64, color: Colors.indigo),
              const SizedBox(height: 16),
              const Text('Global Logi Pro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const Text('Hệ thống Quản lý Vận hành & Telemetry', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              const Text('Chọn phân quyền đăng nhập:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
                onPressed: () => globalState.login('Dispatcher'),
                icon: const Icon(Icons.map),
                label: const Text('Đăng nhập với vai trò Dispatcher (Điều phối)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45), backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () {
                  globalState.login('Driver');
                  globalState.startGpsSimulation();
                },
                icon: const Icon(Icons.local_shipping),
                label: const Text('Đăng nhập với vai trò Driver (Tài xế)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45), backgroundColor: Colors.orange, foregroundColor: Colors.white),
                onPressed: () => globalState.login('Admin'),
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Đăng nhập với vai trò Admin (Quản trị)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainWorkspaceShell extends StatelessWidget {
  const MainWorkspaceShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Role: ${globalState.currentRole}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => globalState.logout(),
          ),
        ],
      ),
      body: const WorkspaceRouter(),
    );
  }
}

class WorkspaceRouter extends StatelessWidget {
  const WorkspaceRouter({super.key});

  @override
  Widget build(BuildContext context) {
    if (globalState.currentRole == 'Driver') {
      return const DriverWorkspaceScreen();
    } else if (globalState.currentRole == 'Dispatcher') {
      return const DispatcherScreen();
    } else {
      return const ControlCenterScreen();
    }
  }
}

class DispatcherScreen extends StatelessWidget {
  const DispatcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: globalState,
      builder: (context, _) {
        final list = globalState.filteredOrders;
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Tìm kiếm đơn hàng (Mã, Khách, Tuyến)',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => globalState.setSearchQuery(val),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Tất cả', 'Mới tạo', 'Đang tìm tài xế', 'Đã nhận'].map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: globalState.filterStatus == status,
                        onSelected: (selected) => globalState.setFilterStatus(status),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('Không tìm thấy đơn hàng phù hợp'))
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final o = list[index];
                          return Card(
                            child: ListTile(
                              title: Text('${o.id} - ${o.customer}'),
                              subtitle: Text('Tuyến: ${o.route} | Cước: ${o.price}đ'),
                              trailing: Chip(
                                label: Text(o.status),
                                backgroundColor: o.status == 'Đã nhận' ? Colors.green[100] : Colors.amber[100],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DriverWorkspaceScreen extends StatelessWidget {
  const DriverWorkspaceScreen({super.key});

  Future<void> _openMap(BuildContext context, String route) async {
    final encodedRoute = Uri.encodeComponent(route);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedRoute');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở bản đồ!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: globalState,
      builder: (context, _) {
        final list = globalState.filteredOrders;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              color: Colors.indigo[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GPS Telemetry & Tọa độ thực tế', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    const SizedBox(height: 6),
                    Text('Vĩ độ (Lat): ${globalState.driverLat.toStringAsFixed(4)}'),
                    Text('Kinh độ (Lng): ${globalState.driverLng.toStringAsFixed(4)}'),
                    Text('Tốc độ: ${globalState.driverSpeed.toStringAsFixed(1)} km/h', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
            ),
            SwitchListTile(
              title: Text('Trạng thái: ${globalState.isOnline ? "Online (Nhận đơn & GPS Active)" : "Offline"}'),
              value: globalState.isOnline,
              activeColor: Colors.green,
              onChanged: (val) => globalState.toggleDriverStatus(val),
            ),
            const Divider(),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm đơn hàng',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => globalState.setSearchQuery(val),
            ),
            const SizedBox(height: 10),
            const Text('Đơn hàng chờ nhận', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ...list.map((o) => Card(
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
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _openMap(context, o.route),
                          icon: const Icon(Icons.navigation, size: 16),
                          label: const Text('Chỉ đường'),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                          onPressed: o.status == 'Đã nhận' ? null : () {
                            globalState.updateOrderStatus(o.id, 'Đã nhận');
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã nhận đơn ${o.id} thành công!')));
                          },
                          icon: const Icon(Icons.check),
                          label: Text(o.status == 'Đã nhận' ? 'Đã nhận' : 'Nhận đơn ngay'),
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
    );
  }
}

class ControlCenterScreen extends StatelessWidget {
  const ControlCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: globalState,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Thống kê hệ thống Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Card(child: ListTile(leading: Icon(Icons.security, color: Colors.green), title: Text('Trạng thái API Gateway'), trailing: Text('Optimal'))),
            const Card(child: ListTile(leading: Icon(Icons.people, color: Colors.blue), title: Text('Tài xế hoạt động GPS'), trailing: Text('1 active'))),
            Card(child: ListTile(leading: const Icon(Icons.shopping_cart, color: Colors.orange), title: const Text('Tổng đơn trong hệ thống'), trailing: Text('${globalState.orders.length}'))),
            const Divider(),
            const Text('Telemetry Trực tuyến', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Card(
              child: ListTile(
                leading: const Icon(Icons.gps_fixed, color: Colors.indigo),
                title: const Text('Tài xế #DRV-88 (Đang di chuyển)'),
                subtitle: Text('Lat: ${globalState.driverLat.toStringAsFixed(4)}, Lng: ${globalState.driverLng.toStringAsFixed(4)}'),
                trailing: Text('${globalState.driverSpeed.toStringAsFixed(1)} km/h', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            ),
          ],
        );
      },
    );
  }
}
