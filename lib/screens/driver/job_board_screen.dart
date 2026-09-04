import 'package:flutter/material.dart';

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  final List<Map<String, dynamic>> _availableJobs = [
    {'title': 'Tài xế container tuyến Bắc - Nam', 'employer': 'Global Logistics Corp', 'salary': '25,000,000 VND', 'country': 'Vietnam', 'applied': false},
    {'title': 'Tài xế xe tải giao hàng nội thành', 'employer': 'Express Trans VN', 'salary': '12,000,000 VND', 'country': 'Vietnam', 'applied': false},
    {'title': 'Cross-Border Truck Driver (SG - MY)', 'employer': 'ASEAN Haulage', 'salary': '\$2,500 USD', 'country': 'Malaysia', 'applied': false},
  ];

  void _applyJob(int index) {
    setState(() {
      _availableJobs[index]['applied'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ứng tuyển thành công! Nhà tuyển dụng sẽ liên hệ phỏng vấn qua hệ thống.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Việc làm Tài xế Toàn cầu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Danh sách công việc phù hợp với hồ sơ của bạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _availableJobs.length,
                itemBuilder: (context, index) {
                  final job = _availableJobs[index];
                  bool isApplied = job['applied'];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Công ty: ${job['employer']} | Khu vực: ${job['country']}'),
                          const SizedBox(height: 4),
                          Text('Thu nhập: ${job['salary']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: isApplied ? null : () => _applyJob(index),
                              icon: Icon(isApplied ? Icons.check : Icons.send, size: 16),
                              label: Text(isApplied ? 'Đã ứng tuyển' : 'Ứng tuyển ngay'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isApplied ? Colors.grey : Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
