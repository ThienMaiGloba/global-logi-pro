import 'package:flutter/material.dart';
import "driver_map_screen.dart";

class DriverProfileSetupScreen extends StatefulWidget {
  const DriverProfileSetupScreen({super.key});

  @override
  State<DriverProfileSetupScreen> createState() => _DriverProfileSetupScreenState();
}

class _DriverProfileSetupScreenState extends State<DriverProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCountry = 'Vietnam';
  String _selectedLicense = 'B2';
  String _selectedVehicle = 'Xe tải nhẹ (< 3.5 tấn)';
  final _experienceController = TextEditingController();
  final _languagesController = TextEditingController(text: 'Tiếng Việt, English');

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hồ sơ tài xế đã được lưu và gửi hệ thống kiểm duyệt thành công!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khai báo Hồ sơ Tài xế')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Thông tin chuyên môn & Phương tiện',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: const InputDecoration(labelText: 'Quốc gia / Khu vực hoạt động', border: OutlineInputBorder()),
                items: ['Vietnam', 'Thailand', 'Malaysia', 'Singapore', 'USA', 'Australia']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCountry = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _languagesController,
                decoration: const InputDecoration(labelText: 'Ngôn ngữ sử dụng', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Vui lòng nhập ngôn ngữ' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLicense,
                decoration: const InputDecoration(labelText: 'Loại Bằng lái (License Class)', border: OutlineInputBorder()),
                items: ['B1', 'B2', 'C', 'D', 'E', 'FC', 'International IDP']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedLicense = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(labelText: 'Số năm kinh nghiệm', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Vui lòng nhập số năm kinh nghiệm' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedVehicle,
                decoration: const InputDecoration(labelText: 'Loại phương tiện & Tải trọng', border: OutlineInputBorder()),
                items: ['Xe tải nhẹ (< 3.5 tấn)', 'Xe tải trung (3.5 - 10 tấn)', 'Xe container / Đầu kéo', 'Xe khách / Bus']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedVehicle = val!),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Gửi hồ sơ xét duyệt'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
