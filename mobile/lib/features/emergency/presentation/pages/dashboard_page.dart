import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../bloc/emergency_bloc.dart';
import '../bloc/emergency_event.dart';
import '../bloc/emergency_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Timer? _timer;
  int _countdown = 3;
  bool _isHolding = false;

  void _startCountdown(VoidCallback onComplete) {
     setState(() {
       _isHolding = true;
       _countdown = 3;
     });
     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
       if (_countdown > 1) {
         setState(() {
           _countdown--;
         });
       } else {
         _cancelCountdown(); 
         onComplete();
       }
     });
  }

  void _cancelCountdown() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
         _isHolding = false;
         _countdown = 3;
      });
    }
  }

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
      ),
      body: BlocConsumer<EmergencyBloc, EmergencyState>(
        listener: (context, state) {
          if (state is SosTriggered) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SOS Activated! Emergency services notified.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          } else if (state is EmergencyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isActivated = state is SosTriggered;
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                   const SizedBox(height: 40),
                   // SOS Button
                   Center(
                     child: GestureDetector(
                       onTapDown: (_) => _startCountdown(
                         isActivated 
                           ? () {
                               final alertId = state.alert.id;
                               context.read<EmergencyBloc>().add(CancelSosEvent(alertId));
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Deactivating SOS...')),
                               );
                             }
                           : _checkAndTriggerSos
                       ),
                       onTapUp: (_) => _cancelCountdown(),
                       onTapCancel: () => _cancelCountdown(),
                       onTap: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('Hold button for 3 seconds to ${isActivated ? "cancel" : "trigger"} SOS')),
                           );
                       },
                       child: AnimatedContainer(
                         duration: const Duration(milliseconds: 300),
                         height: 250,
                         width: 250,
                         decoration: BoxDecoration(
                           color: isActivated ? Colors.red : Colors.green.shade400, // Red if active, Green if safe
                           shape: BoxShape.circle,
                           boxShadow: [
                             BoxShadow(
                               color: (isActivated ? Colors.red : Colors.green).withOpacity(0.4),
                               blurRadius: 30,
                               spreadRadius: 10,
                             ),
                           ],
                         ),
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(
                               isActivated ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                               color: Colors.white,
                               size: 64,
                             ),
                             const SizedBox(height: 10),
                             Text(
                               isActivated 
                                 ? (_isHolding ? "CANCELLING $_countdown..." : "SOS ACTIVATED")
                                 : (_isHolding ? "SENDING IN $_countdown..." : "YOU ARE SAFE"),
                               style: GoogleFonts.bebasNeue(
                                 fontSize: 32,
                                 color: Colors.white,
                                 letterSpacing: 2,
                               ),
                             ),
                             const SizedBox(height: 5),
                             Text(
                               isActivated 
                                 ? (_isHolding ? "Keep Holding" : "Hold to Mark Safe")
                                 : (_isHolding ? "Keep Holding" : "Hold for SOS"),
                               style: const TextStyle(
                                 color: Colors.white70,
                                 fontSize: 16,
                               ),
                             ),
                           ],
                         ),
                       ),
                     ),
                   ),
                   
                   const SizedBox(height: 60),

                  // Quick Actions Grid (Restored)
                   GridView.count(
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       crossAxisCount: 2,
                       crossAxisSpacing: 16,
                       mainAxisSpacing: 16,
                       children: [
                         _buildQuickActionCard(
                           context,
                           'Friend Walk',
                           Icons.directions_walk,
                           Colors.cyan,
                           () => context.push('/friend-walk'),
                         ),
                         _buildQuickActionCard(
                           context,
                           'Report Incident',
                           Icons.report_problem,
                           Colors.orange,
                           () => context.push('/report'),
                         ),
                         _buildQuickActionCard(
                           context,
                           'Safety Timer',
                           Icons.timer,
                           Colors.blue,
                           () => context.push('/safety-timer'),
                         ),
                         _buildQuickActionCard(
                           context,
                           'Mental Health',
                           Icons.favorite,
                           Colors.teal,
                           () => context.push('/mental-health'),
                         ),
                       ],
                     ),
                     const SizedBox(height: 20),
                     // Admin Access (Admin/Super Admin only)
                     BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          if (authState is AuthAuthenticated && authState.user.role != 'student') {
                             return TextButton.icon(
                                onPressed: () => context.push('/admin'),
                                icon: const Icon(Icons.admin_panel_settings),
                                label: const Text("Go to Admin Console"),
                             );
                          }
                          return const SizedBox.shrink();
                        },
                     ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

