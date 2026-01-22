import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../injection_container.dart';
import '../bloc/friend_walk_bloc.dart';
import '../bloc/friend_walk_event.dart';
import '../bloc/friend_walk_state.dart';
import '../../../campus_compass/presentation/bloc/campus_compass_bloc.dart';
import '../../../campus_compass/presentation/bloc/campus_compass_event.dart';
import '../../../campus_compass/presentation/bloc/campus_compass_state.dart';

class FriendWalkPage extends StatefulWidget {
  const FriendWalkPage({super.key});

  @override
  State<FriendWalkPage> createState() => _FriendWalkPageState();
}

class _FriendWalkPageState extends State<FriendWalkPage> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  late AnimationController _dangerPulseController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _dangerPulseController = AnimationController(
        vsync: this, duration: const Duration(seconds: 1)
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dangerPulseController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    // ... permission checks ...
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

     LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    
    // Move map to location if available and first load
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CampusCompassBloc>()..add(StartRadar()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Friend Walk')),
        body: MultiBlocListener(
          listeners: [
            BlocListener<FriendWalkBloc, FriendWalkState>(
              listener: (context, state) {
                 if (state is FriendWalkError) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                 }
              },
            ),
            BlocListener<CampusCompassBloc, CampusCompassState>(
              listener: (context, state) {
                if (state is CampusCompassActive && state.nearbyAlertMessage != null) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: Text("WARNING: ${state.nearbyAlertMessage}", style: const TextStyle(fontWeight: FontWeight.bold)),
                       backgroundColor: Colors.red,
                       duration: const Duration(seconds: 5),
                     )
                   );
                }
              },
            ),
          ],
          child: BlocBuilder<FriendWalkBloc, FriendWalkState>(
            builder: (context, walkState) {
              return BlocBuilder<CampusCompassBloc, CampusCompassState>(
                builder: (context, compassState) {
                  
                  // Combine markers
                  List<Marker> markers = [];
                  List<CircleMarker> circles = [];
                  List<Polygon> polygons = [];

                  // 1. My Location (Blue)
                  if (_currentPosition != null) {
                    markers.add(
                      Marker(
                        point: _currentPosition!,
                        width: 80,
                        height: 80,
                        child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
                      ),
                    );
                  }

                  // 2. SOS Alerts (Red) from CampusCompass
                  if (compassState is CampusCompassActive) {
                    // Static Danger Zones
                     for (var zone in compassState.dangerZones) {
                       polygons.add(
                         Polygon(
                           points: zone.coordinates,
                           color: zone.riskLevel == 'High' 
                              ? Colors.red.withOpacity(0.4) 
                              : Colors.orange.withOpacity(0.4),
                           borderColor: zone.riskLevel == 'High' ? Colors.red : Colors.orange,
                           borderStrokeWidth: 2,
                         )
                       );
                     }

                    for (var alert in compassState.activeAlerts) {
                       // Danger Zone Circle
                       circles.add(
                         CircleMarker(
                           point: LatLng(alert.latitude, alert.longitude),
                           color: Colors.red.withOpacity(0.3),
                           borderColor: Colors.red,
                           borderStrokeWidth: 2,
                           useRadiusInMeter: true,
                           radius: 100,
                         )
                       );
                       // Pulsing Icon
                       markers.add(
                         Marker(
                           point: LatLng(alert.latitude, alert.longitude),
                           width: 60,
                           height: 60,
                           child: AnimatedBuilder(
                             animation: _dangerPulseController,
                             builder: (context, child) {
                               return Transform.scale(
                                 scale: 1.0 + (_dangerPulseController.value * 0.3),
                                 child: const Icon(Icons.warning, color: Colors.red, size: 40),
                               );
                             },
                           ),
                         )
                       );
                    }
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: _currentPosition == null
                            ? const Center(child: CircularProgressIndicator())
                            : FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: _currentPosition!,
                                  initialZoom: 15.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.safecampus.app',
                                  ),
                                  PolygonLayer(polygons: polygons),
                                  CircleLayer(circles: circles),
                                  MarkerLayer(markers: markers),
                                ],
                              ),
                      ),
              Container(
                padding: const EdgeInsets.all(16),
                child: walkState is FriendWalkActive 
                ? Row(
                    children: [
                       Expanded(
                         child: ElevatedButton(
                           onPressed: () {
                             context.read<FriendWalkBloc>().add(const EndWalkRequested());
                           },
                           style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                           child: const Text('End Walk'),
                         ),
                       ),
                       const SizedBox(width: 10),
                       OutlinedButton(
                         onPressed: () {
                            // Minimize / Go Back but keep walk active
                            Navigator.of(context).pop();
                         },
                         child: const Text('Run in Background'),
                       )
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      // Hardcoded friend ID for now
                      context.read<FriendWalkBloc>().add(const StartWalkRequested("me", "friend-123"));
                    },
                    child: walkState is FriendWalkLoading 
                      ? const CircularProgressIndicator()
                      : const Text('Start Friend Walk'),
                  ),
              ),
            ],
          );
        },
      );
            },
          ),
        ),
      ),
    );
  }
}
