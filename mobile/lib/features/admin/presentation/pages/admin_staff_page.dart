import 'package:flutter/material.dart';

class AdminStaffPage extends StatelessWidget {
  const AdminStaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Staff')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Invite New Admin'),
              subtitle: Text('Generate an invitation link'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const SizedBox(height: 10),
          const Card(
            child: ListTile(
              leading: Icon(Icons.upgrade),
              title: Text('Promote Student'),
              subtitle: Text('Upgrade existing user to admin'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
        ],
      ),
    );
  }
}
