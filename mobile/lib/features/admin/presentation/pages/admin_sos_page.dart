import 'package:flutter/material.dart';

class AdminSosPage extends StatelessWidget {
  const AdminSosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitor SOS Alerts')),
      body: const Center(child: Text('Live SOS feed will appear here')),
    );
  }
}
