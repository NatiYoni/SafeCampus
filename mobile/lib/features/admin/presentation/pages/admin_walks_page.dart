import 'package:flutter/material.dart';

class AdminWalksPage extends StatelessWidget {
  const AdminWalksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Friend Walks')),
      body: const Center(child: Text('Map of active walks will appear here')),
    );
  }
}
