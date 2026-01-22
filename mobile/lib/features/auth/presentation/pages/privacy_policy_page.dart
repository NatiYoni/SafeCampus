import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Policy')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Effective Date: January 1, 2024\n\n'
              'Welcome to SafeCampus. We are committed to protecting your privacy and ensuring your safety.\n\n'
              '1. Information We Collect\n'
              'We collect personal information such as your name, university ID, phone number, and location data when you use safety features (Friend Walk, SOS).\n\n'
              '2. How We Use Your Information\n'
              '- To provide emergency services.\n'
              '- To verify your identity within the university.\n'
              '- To facilitate communication with safety contacts.\n\n'
              '3. Location Data\n'
              'Your location is only tracked when you explicitly activate safety features like "Friend Walk" or "SOS". We do not track you in the background without permission.\n\n'
              '4. Data Security\n'
              'We implement security measures to protect your data. However, no method of transmission is 100% secure.\n\n'
              '5. Contact Us\n'
              'If you have questions, please contact campus security.\n',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
