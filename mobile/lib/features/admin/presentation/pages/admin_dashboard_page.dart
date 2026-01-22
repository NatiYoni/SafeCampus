import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';


class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              final authBloc = context.read<AuthBloc>();
              final state = authBloc.state;
              if (state is AuthAuthenticated) {
                if (state.user.role == 'super_admin') {
                  authBloc.add(LogoutEvent());
                  // Navigation handled by auth listener, usually
                } else {
                  // Promoted Student/Staff -> Return to Dashboard
                  context.go('/dashboard');
                }
              } else {
                context.go('/');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Operations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    Icons.notifications_active,
                    'Monitor SOS',
                    Colors.redAccent,
                    () => context.push('/admin/sos'),
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.warning_amber,
                    'Review Reports',
                    Colors.orangeAccent,
                    () => context.push('/admin/reports'),
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.map,
                    'Active Walks',
                    Colors.green,
                    () => context.push('/admin/walks'),
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.admin_panel_settings,
                    'Manage Staff',
                    Colors.blue,
                    () => context.push('/admin/staff'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 30,
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
