import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/friend_walk_bloc.dart';
import '../bloc/friend_walk_event.dart';
import '../bloc/friend_walk_state.dart';

class FriendWalkPage extends StatefulWidget {
  const FriendWalkPage({super.key});

  @override
  State<FriendWalkPage> createState() => _FriendWalkPageState();
}

class _FriendWalkPageState extends State<FriendWalkPage> {
  GoogleMapController? _controller;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend Walk')),
      body: BlocConsumer<FriendWalkBloc, FriendWalkState>(
        listener: (context, state) {
           if (state is FriendWalkError) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
           }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition!,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) => _controller = controller,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: state is FriendWalkActive 
                ? ElevatedButton(
                    onPressed: () {
                      context.read<FriendWalkBloc>().add(const EndWalkRequested());
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('End Walk'),
                  )
                : ElevatedButton(
                    onPressed: () {
                      // Hardcoded friend ID for now
                      context.read<FriendWalkBloc>().add(const StartWalkRequested("me", "friend-123"));
                    },
                    child: state is FriendWalkLoading 
                      ? const CircularProgressIndicator()
                      : const Text('Start Friend Walk'),
                  ),
              ),
            ],
          );
        },
      ),
    );
  }
}
