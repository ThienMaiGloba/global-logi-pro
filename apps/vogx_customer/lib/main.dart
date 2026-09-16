import 'package:flutter/material.dart';
import 'package:vogx_core/vogx_core.dart';

void main() {
  runApp(const VogxApp());
}

class VogxApp extends StatelessWidget {
  const VogxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VOGX Customer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CustomerHomeScreen(),
    );
  }
}

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final api = ApiClient('http://192.168.1.42:3000');

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final pickupAddressController = TextEditingController();
  final deliveryAddressController = TextEditingController();
  final priceController = TextEditingController(text: '150000');
  final notesController = TextEditingController();

  String status = 'VOGX Customer sẵn sàng';
  String? userId;
  double? latitude;
  double? longitude;
  bool busy = false;

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    pickupAddressController.dispose();
    deliveryAddressController.dispose();
    priceController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> checkBackend() async {
    setState(() {
      busy = true;
      status = 'Đang kiểm tra Backend...';
    });

    try {
      final result = await api.get('/api/health');

      if (!mounted) return;

      setState(() {
        status = 'Backend OK: $result';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        status = 'Backend lỗi: $e';
      });
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> login() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      setState(() {
        status = 'Vui lòng nhập số điện thoại và mật khẩu';
      });
      return;
    }

    setState(() {
      busy = true;
      status = 'Đang đăng nhập...';
    });

    try {
      final result = await api.post(
        '/api/auth/login',
        {
          'phone': phone,
          'password': password,
        },
      );

      final token = result['accessToken']?.toString();

      if (token == null || token.isEmpty) {
        throw Exception('Backend không trả accessToken');
      }

      api.accessToken = token;

      final user = result['user'];
      userId = user is Map ? user['id']?.toString() : null;

      if (!mounted) return;

      setState(() {
        status = 'Đăng nhập thành công: ${user ?? ''}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        status = 'Đăng nhập lỗi: $e';
      });
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> locate() async {
    setState(() {
      busy = true;
      status = 'Đang lấy GPS thật từ điện thoại...';
    });

    try {
      final position = await LocationService.current();

      if (!mounted) return;

      if (position == null) {
        setState(() {
          status = 'Không lấy được GPS. Kiểm tra quyền vị trí.';
        });
        return;
      }

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        status =
            'GPS thật: ${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        status = 'GPS lỗi: $e';
      });
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> createOrder() async {
    if (api.accessToken == null) {
      setState(() {
        status = 'Cần đăng nhập Customer trước khi tạo đơn';
      });
      return;
    }

    if (latitude == null || longitude == null) {
      setState(() {
        status = 'Cần lấy GPS thật trước khi tạo đơn';
      });
      return;
    }

    final pickupAddress = pickupAddressController.text.trim();
    final deliveryAddress = deliveryAddressController.text.trim();
    final price = int.tryParse(priceController.text.trim());

    if (pickupAddress.isEmpty || deliveryAddress.isEmpty) {
      setState(() {
        status = 'Vui lòng nhập địa chỉ lấy hàng và giao hàng';
      });
      return;
    }

    if (price == null || price < 0) {
      setState(() {
        status = 'Giá đơn không hợp lệ';
      });
      return;
    }

    final idempotencyKey =
        'customer-${DateTime.now().microsecondsSinceEpoch}';

    setState(() {
      busy = true;
      status = 'Đang tạo Order thật trên Backend...';
    });

    try {
      final result = await api.post(
        '/api/orders',
        {
          'price': price,
          'notes': notesController.text.trim().isEmpty
              ? null
              : notesController.text.trim(),
          'idempotencyKey': idempotencyKey,
          'stops': [
            {
              'sequence': 0,
              'type': 'PICKUP',
              'latitude': latitude,
              'longitude': longitude,
              'address': pickupAddress,
            },
            {
              'sequence': 1,
              'type': 'DELIVERY',
              'latitude': latitude,
              'longitude': longitude,
              'address': deliveryAddress,
            },
          ],
        },
      );

      if (!mounted) return;

      setState(() {
        status = 'TẠO ORDER THÀNH CÔNG\n\n'
            'Order ID: ${result['id']}\n'
            'Customer ID: ${result['customerId']}\n'
            'Status: ${result['status']}\n'
            'Price: ${result['price']}\n'
            'Stops: ${(result['stops'] as List?)?.length ?? 0}\n'
            'GPS pickup: $latitude, $longitude';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        status = 'Tạo Order lỗi: $e';
      });
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> openNavigation() async {
    if (latitude == null || longitude == null) {
      setState(() {
        status = 'Cần lấy GPS thật trước';
      });
      return;
    }

    final ok = await NavigationService.navigateTo(
      latitude: latitude!,
      longitude: longitude!,
      label: 'VOGX Customer GPS',
    );

    if (!mounted) return;

    setState(() {
      status = ok
          ? 'Đã mở ứng dụng bản đồ điện thoại'
          : 'Không mở được ứng dụng bản đồ';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VOGX Customer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.local_shipping, size: 72),
          const SizedBox(height: 12),
          Text(
            'VOGX Customer — Real E2E',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(status),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            '1. Đăng nhập Customer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 8),

          FilledButton.icon(
            onPressed: busy ? null : login,
            icon: const Icon(Icons.login),
            label: const Text('Đăng nhập Customer thật'),
          ),

          const SizedBox(height: 20),

          const Text(
            '2. Kiểm tra kết nối & GPS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          FilledButton.icon(
            onPressed: busy ? null : checkBackend,
            icon: const Icon(Icons.cloud),
            label: const Text('Kiểm tra Backend'),
          ),

          FilledButton.icon(
            onPressed: busy ? null : locate,
            icon: const Icon(Icons.my_location),
            label: const Text('Lấy GPS thật'),
          ),

          if (latitude != null && longitude != null) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.gps_fixed),
                title: const Text('GPS thật hiện tại'),
                subtitle: Text(
                  'Latitude: $latitude\nLongitude: $longitude',
                ),
              ),
            ),
          ],

          FilledButton.icon(
            onPressed: busy ? null : openNavigation,
            icon: const Icon(Icons.navigation),
            label: const Text('Mở bản đồ điện thoại'),
          ),

          const SizedBox(height: 20),

          const Text(
            '3. Tạo Order thật',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: pickupAddressController,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ lấy hàng',
              hintText: 'Nhập địa chỉ thật',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: deliveryAddressController,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ giao hàng',
              hintText: 'Nhập địa chỉ thật',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Giá đơn (VND)',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Ghi chú',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 8),

          FilledButton.icon(
            onPressed: busy ? null : createOrder,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('TẠO ORDER THẬT'),
          ),

          if (userId != null) ...[
            const SizedBox(height: 8),
            Text(
              'Customer ID: $userId',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
