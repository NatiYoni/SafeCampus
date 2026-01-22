import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import 'profile_page.dart';
import 'change_password_page.dart';
import 'privacy_policy_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
           // We expect the user to be authenticated to see this page.
           if (state is AuthAuthenticated) {
             final user = state.user;
             return ListView(
               children: [
                 const SizedBox(height: 20),
                 // User Info Header
                 Center(
                   child: CircleAvatar(
                     radius: 40,
                     backgroundColor: Colors.indigo.shade100,
                     child: Text(
                       user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                       style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                     ),
                   ),
                 ),
                 const SizedBox(height: 10),
                 Center(
                   child: Text(
                     user.fullName,
                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                   ),
                 ),
                 Center(
                   child: Text(
                     user.email,
                     style: const TextStyle(color: Colors.grey),
                   ),
                 ),
                 const SizedBox(height: 30),

                 const Divider(),
                 
                 // Account Settings
                 ListTile(
                   leading: const Icon(Icons.person),
                   title: const Text('My Profile'),
                   subtitle: const Text('Edit personal information'),
                   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                   onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                   },
                 ),
                 ListTile(
                   leading: const Icon(Icons.lock),
                   title: const Text('Change Password'),
                   subtitle: const Text('Update your security'),
                   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                   onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
                   },
                 ),

                 const Divider(),

                 // Legal
                 ListTile(
                   leading: const Icon(Icons.policy),
                   title: const Text('Privacy & Policy'),
                   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                   onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()));
                   },
                 ),

                 const Divider(),

                 // Logout
                 ListTile(
                   leading: const Icon(Icons.logout, color: Colors.red),
                   title: const Text('Log Out', style: TextStyle(color: Colors.red)),
                   onTap: () {
                     _showLogoutDialog(context);
                   },
                 ),
               ],
             );
           }
           return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.read<AuthBloc>().add(LogoutEvent());
              // Router will listen to state change and redirect
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
