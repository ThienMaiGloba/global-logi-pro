import 'package:flutter/material.dart';

class DispatcherScreen extends StatelessWidget {
  const DispatcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispatcher Realtime Operations Dashboard')),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[200],
              child: const Center(
                child: Text('MapLibre GL Vector Map View\n(Active Fleet & Geofencing)', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Live Active Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: const [
                        ListTile(
                          title: Text('Order #8821'),
                          subtitle: Text('Status: Searching Driver...'),
                          trailing: Chip(label: Text('Bike', style: TextStyle(fontSize: 10)), backgroundColor: Colors.amber),
                        ),
                        ListTile(
                          title: Text('Order #8822'),
                          subtitle: Text('Status: In Transit'),
                          trailing: Chip(label: Text('Truck', style: TextStyle(fontSize: 10)), backgroundColor: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
