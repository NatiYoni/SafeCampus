import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/admin_walks_bloc.dart';
import '../bloc/admin_walks_event.dart';
import '../bloc/admin_walks_state.dart';
import '../bloc/admin_sos_bloc.dart';
import '../bloc/admin_sos_event.dart';
import '../bloc/admin_sos_state.dart';
import '../../../emergency/domain/entities/alert.dart';

class AdminWalksPage extends StatefulWidget {
  const AdminWalksPage({super.key});

  @override
  State<AdminWalksPage> createState() => _AdminWalksPageState();
}

class _AdminWalksPageState extends State<AdminWalksPage> with SingleTickerProviderStateMixin {
  Timer? _refreshTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _refresh();
    // Auto-refresh every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
    
    _pulseController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  void _refresh() {
    context.read<AdminWalksBloc>().add(FetchActiveWalks());
    context.read<AdminSosBloc>().add(LoadAdminSos());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Campus Safety Map')),
      body: Stack(
        children: [
          _buildMap(),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return BlocBuilder<AdminWalksBloc, AdminWalksState>(
      builder: (context, walkState) {
        return BlocBuilder<AdminSosBloc, AdminSosState>(
          builder: (context, sosState) {
            
            // Collect Data
            final walks = (walkState is AdminWalksLoaded) ? walkState.activeWalks : [];
            final alerts = (sosState is AdminSosLoaded) ? sosState.alerts : [];
            final activeAlerts = alerts.toList(); // Assuming all returned are active or filter if needed

            return FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(9.0300, 38.7430), // Default 
                initialZoom: 14.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.safecampus.app',
                ),
                // 1. Danger Zones (Red Circles)
                CircleLayer(
                  circles: activeAlerts.map((alert) {
                     return CircleMarker(
                       point: LatLng(alert.latitude, alert.longitude),
                       color: Colors.red.withOpacity(0.3),
                       borderColor: Colors.red,
                       borderStrokeWidth: 2,
                       useRadiusInMeter: true,
                       radius: 100, // 100m Safety/Danger Zone
                     );
                  }).toList(),
                ),
                // 2. Markers
                MarkerLayer(
                  markers: [
                    // Walkers
                    ...walks.map((walk) => Marker(
                      point: LatLng(walk.currentLocation.latitude, walk.currentLocation.longitude),
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.directions_walk, color: Colors.purple, size: 40),
                    )),
                    // SOS Alerts
                    ...activeAlerts.map((alert) => Marker(
                      point: LatLng(alert.latitude, alert.longitude),
                      width: 60,
                      height: 60,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseController.value * 0.3),
                            child: const Icon(Icons.warning_rounded, color: Colors.red, size: 50),
                          );
                        },
                      ),
                    )),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
             BoxShadow(color: Colors.black26, blurRadius: 5)
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _legendItem(Colors.purple, "Active Walk"),
            _legendItem(Colors.red, "SOS Alert"),
            _legendItem(Colors.red.withOpacity(0.5), "100m Danger Zone"),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
