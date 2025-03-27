import 'package:flutter/material.dart';
import 'package:flutter_app/screens/customers_screen.dart';

class OthersScreen extends StatelessWidget {
  const OthersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Customers'),
            trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomersScreen()),
                );
              }
          ),
          // Add more list items for other options
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}