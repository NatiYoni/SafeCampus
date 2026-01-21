import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/emergency_bloc.dart';
import '../bloc/emergency_event.dart';
import '../bloc/emergency_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<void> _checkAndTriggerSos() async {
    // 1. Check Service Status
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Location Required"),
          content: const Text("Location services are required for SOS. Please turn them on."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openLocationSettings();
                // Recursively check until enabled or user cancels
                _checkAndTriggerSos();
              },
              child: const Text("Turn On & Retry"),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Check Permissions (Optional, but good practice to prevent exceptions)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permission denied")));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permission permanently denied")));
      return;
    }

    if (!mounted) return;
    context.read<EmergencyBloc>().add(const TriggerSosEvent("user-123")); 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sending SOS Signal...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Campus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              // Open Chat
            },
          ),
        ],
      ),
      body: BlocConsumer<EmergencyBloc, EmergencyState>(
        listener: (context, state) {
          if (state is SosTriggered) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SOS Signal Received! Help is on the way.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
              ),
            );
          } else if (state is EmergencyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is EmergencyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Show "I Am Safe" button if SOS is active (state is SosTriggered)
          if (state is SosTriggered) {
             return Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Text(
                   "SOS Active!",
                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                 ),
                 const SizedBox(height: 20),
                 const CircularProgressIndicator(color: Colors.red),
                 const SizedBox(height: 20),
                 ElevatedButton.icon(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.green,
                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                   ),
                   onPressed: () {
                     context.read<EmergencyBloc>().add(CancelSosEvent(state.alert.id));
                   },
                   icon: const Icon(Icons.check_circle),
                   label: const Text("I Am Safe", style: TextStyle(fontSize: 20)),
                 ),
               ],
             );
          }

          return Column(
            children: [
              // Emergency SOS Section
              Expanded(
                flex: 2,
                child: Center(
                  child: GestureDetector(
                    onLongPress: _checkAndTriggerSos,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sos, size: 60, color: Colors.white),
                          Text(
                            'HOLD FOR SOS',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
          // Features Grid
          Expanded(
            flex: 2,
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  context,
                  Icons.directions_walk,
                  'Friend Walk',
                  Colors.green,
                  () => context.push('/friend-walk'),
                ),
                _buildFeatureCard(
                  context,
                  Icons.warning,
                  'Report Hazard',
                  Colors.orange,
                  () => context.push('/report'),
                ),
                _buildFeatureCard(
                  context,
                  Icons.access_time,
                  'Safety Timer',
                  Colors.blue,
                  () => context.push('/safety-timer'),
                ),
                _buildFeatureCard(
                  context,
                  Icons.psychology,
                  'Mental Health',
                  Colors.purple,
                  () => context.push('/mental-health'),
                ),
              ],
            ),
          ),

          // Temporary Admin Access for Demo
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextButton.icon(
                onPressed: () => context.push('/admin'),
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text("Go to Admin Console"),
              ),
            ),
          ),
        ],
      );
        },
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
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
