import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/usecases/start_walk.dart';
import '../../domain/usecases/update_location.dart';
import '../../domain/usecases/end_walk.dart';
import 'friend_walk_event.dart';
import 'friend_walk_state.dart';

class FriendWalkBloc extends Bloc<FriendWalkEvent, FriendWalkState> {
  final StartWalk startWalk;
  final UpdateWalkLocation updateWalkLocation;
  final EndWalk endWalk;
  
  String? currentWalkId;
  StreamSubscription<Position>? _positionSubscription;

  FriendWalkBloc({
    required this.startWalk, 
    required this.updateWalkLocation,
    required this.endWalk,
  }) : super(FriendWalkInitial()) {
    on<StartWalkRequested>((event, emit) async {
      emit(FriendWalkLoading());
      final result = await startWalk(StartWalkParams(userId: event.userId, guardianId: event.guardianId));
      result.fold(
        (failure) => emit(FriendWalkError(failure.message)),
        (session) {
          currentWalkId = session.id;
          emit(FriendWalkActive(session));
          _startLocationTracking();
        },
      );
    });

    on<LocationUpdated>((event, emit) async {
      if (state is FriendWalkActive && currentWalkId != null) {
        await updateWalkLocation(UpdateWalkLocationParams(
          walkId: currentWalkId!,
          lat: event.lat,
          lng: event.lng,
        ));
      }
    });

    on<EndWalkRequested>((event, emit) async {
       if (currentWalkId != null) {
         await endWalk(currentWalkId!);
       }
       _stopLocationTracking();
       currentWalkId = null;
       emit(FriendWalkInitial());
    });
  }

  void _startLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      add(LocationUpdated(position.latitude, position.longitude));
    });
  }

  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  Future<void> close() {
    _stopLocationTracking();
    return super.close();
  }
}
