import 'package:flutter/material.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control Center & RBAC Administration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildStatCard('Total Active Drivers', '1,248', Icons.people, Colors.blue),
            _buildStatCard('Pending Orders', '54', Icons.pending_actions, Colors.orange),
            _buildStatCard('Completed Today', '3,892', Icons.check_circle, Colors.green),
            _buildStatCard('System Health', 'Optimal (Zero Bottlenecks)', Icons.security, Colors.purple),
            const Divider(height: 32),
            const Text('RBAC & Role Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Super Administrator'),
              subtitle: const Text('Full access to all regions, pricing, and server configurations'),
              trailing: Switch(value: true, onChanged: (val){}),
            ),
            ListTile(
              leading: const Icon(Icons.supervisor_account),
              title: const Text('Regional Dispatcher Manager'),
              subtitle: const Text('Manage regional fleets and override stuck dispatches'),
              trailing: Switch(value: true, onChanged: (val){}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}
