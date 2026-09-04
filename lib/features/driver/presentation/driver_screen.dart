import 'package:flutter/material.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  bool _isOnline = false;
  String _statusMessage = 'Offline - Tap to go online';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Workspace & GPS Telemetry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              title: Text(_isOnline ? 'You are ONLINE & Ready' : 'You are OFFLINE'),
              subtitle: Text(_statusMessage),
              value: _isOnline,
              activeColor: Colors.green,
              onChanged: (val) {
                setState(() {
                  _isOnline = val;
                  _statusMessage = val ? 'Broadcasting live GPS telemetry...' : 'Offline - Not receiving orders';
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Assigned Order Dispatch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text('Customer: Nguyen Van A'),
                      const Text('Pickup: District 1, HCMC'),
                      const Text('Dropoff: Thu Duc City'),
                      const Text('Estimated Fare: 150,000 VND'),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              onPressed: _isOnline ? () {} : null,
                              icon: const Icon(Icons.close),
                              label: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              onPressed: _isOnline ? () {} : null,
                              icon: const Icon(Icons.check),
                              label: const Text('Accept'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
