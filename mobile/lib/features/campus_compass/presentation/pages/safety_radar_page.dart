import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection_container.dart';
import '../bloc/campus_compass_bloc.dart';
import '../bloc/campus_compass_event.dart';
import '../bloc/campus_compass_state.dart';
import '../../domain/entities/campus_presence.dart';

class SafetyRadarPage extends StatefulWidget {
  const SafetyRadarPage({super.key});

  @override
  State<SafetyRadarPage> createState() => _SafetyRadarPageState();
}

class _SafetyRadarPageState extends State<SafetyRadarPage> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _myLocation;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  Future<void> _determinePosition() async {
    // Basic geolocator wrapper
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _myLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // Handle permission errors
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CampusCompassBloc>()..add(StartRadar()),
      child: Scaffold(
        body: BlocConsumer<CampusCompassBloc, CampusCompassState>(
          listener: (context, state) {
            if (state is CampusCompassActive && state.nearbyAlertMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.nearbyAlertMessage!, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(seconds: 10),
                  action: SnackBarAction(label: 'VIEW', textColor: Colors.white, onPressed: (){}),
                ),
              );
            }
          },
          builder: (context, state) {
            if (_myLocation == null) {
              return const Center(child: CircularProgressIndicator(color: Colors.indigo));
            }

            List<Marker> markers = [];
            
            // 1. My Location Marker
            markers.add(
              Marker(
                point: _myLocation!,
                width: 60,
                height: 60,
                child: const Icon(Icons.navigation, color: Colors.blueAccent, size: 40),
              ),
            );

            // 2. Others & SOS
            if (state is CampusCompassActive) {
               // Friends/Online Users (Green)
               for (var user in state.onlineUsers) {
                 // Skip rendering myself ideally, but simple for now
                 markers.add(
                   Marker(
                     point: LatLng(user.latitude, user.longitude),
                     width: 40,
                     height: 40,
                     child: const Icon(Icons.location_on, color: Colors.green, size: 30),
                   ),
                 );
               }

               // Active SOS (Red + Pulse)
               for (var alert in state.activeAlerts) {
                 markers.add(
                   Marker(
                     point: LatLng(alert.latitude, alert.longitude),
                     width: 100,
                     height: 100,
                     child: AnimatedBuilder(
                       animation: _pulseController,
                       builder: (context, child) {
                         double opacity = (1.0 - _pulseController.value);
                         return Stack(
                           alignment: Alignment.center,
                           children: [
                             Container(
                               width: 80 * _pulseController.value + 20,
                               height: 80 * _pulseController.value + 20,
                               decoration: BoxDecoration(
                                 shape: BoxShape.circle,
                                 color: Colors.red.withOpacity(opacity * 0.5),
                               ),
                             ),
                             const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
                           ],
                         );
                       },
                     ),
                   ),
                 );
               }
            }

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _myLocation!,
                    initialZoom: 17.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.safecampus.app',
                    ),
                    // Dangerous Zones (100m Radius)
                    if (state is CampusCompassActive)
                      CircleLayer(
                        circles: state.activeAlerts.map((alert) {
                          return CircleMarker(
                            point: LatLng(alert.latitude, alert.longitude),
                            color: Colors.red.withOpacity(0.3),
                            borderColor: Colors.red,
                            borderStrokeWidth: 2,
                            useRadiusInMeter: true,
                            radius: 100, // 100m Danger Zone
                          );
                        }).toList(),
                      ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                
                // Top Bar
                Positioned(
                  top: 50,
                  left: 20,
                  child: FloatingActionButton.small(
                    heroTag: 'back',
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // Map Legend / Status
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, color: Colors.green, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          state is CampusCompassActive ? "${state.onlineUsers.length} Active" : "Scanning...",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Panel
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                       if (state is CampusCompassActive && state.nearbyAlertMessage != null)
                         Container(
                           margin: const EdgeInsets.only(bottom: 15),
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: Colors.red,
                             borderRadius: BorderRadius.circular(12),
                             boxShadow: [
                               BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)
                             ]
                           ),
                           child: Row(
                             children: [
                               const Icon(Icons.warning, color: Colors.white, size: 30),
                               const SizedBox(width: 15),
                               Expanded(
                                 child: Text(
                                   state.nearbyAlertMessage!,
                                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                 ),
                               ),
                             ],
                           ),
                         ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/friend-walk'),
                              icon: const Icon(Icons.directions_walk),
                              label: const Text("Start Friend Walk"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                elevation: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          FloatingActionButton(
                            heroTag: 'center',
                            onPressed: () {
                              if (_myLocation != null) {
                                _mapController.move(_myLocation!, 17);
                              }
                            },
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.my_location, color: Colors.indigo),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
