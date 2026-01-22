import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_campus_status.dart';
import '../../domain/usecases/send_heartbeat.dart';
import '../../domain/entities/zone.dart';
import 'campus_compass_event.dart';
import 'campus_compass_state.dart';

class CampusCompassBloc extends Bloc<CampusCompassEvent, CampusCompassState> {
  final GetCampusStatus getCampusStatus;
  final SendHeartbeat sendHeartbeat;
  Timer? _timer;

  CampusCompassBloc({
    required this.getCampusStatus,
    required this.sendHeartbeat,
  }) : super(CampusCompassInitial()) {
    on<StartRadar>(_onStartRadar);
    on<StopRadar>(_onStopRadar);
    on<RefreshRadar>(_onRefreshRadar);
  }

  void _onStartRadar(StartRadar event, Emitter<CampusCompassState> emit) {
    emit(CampusCompassLoading());
    add(RefreshRadar());
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => add(RefreshRadar())); // 10s loop
  }

  void _onStopRadar(StopRadar event, Emitter<CampusCompassState> emit) {
    _timer?.cancel();
    emit(CampusCompassInitial());
  }

  Future<void> _onRefreshRadar(RefreshRadar event, Emitter<CampusCompassState> emit) async {
    try {
      // 1. Get Current Location
      // We assume permissions are handled by UI before starting radar
      Position position = await Geolocator.getCurrentPosition(); 
      
      // 2. Send Heartbeat
      await sendHeartbeat(CampusHeartbeatParams(
        lat: position.latitude, 
        lng: position.longitude, 
        heading: position.heading, 
        status: 'safe', // Default to safe, UI can override if integrated with SOS bloc
      ));

      // 3. Fetch Status
      final result = await getCampusStatus(NoParams());
      
      result.fold(
        (failure) => emit(CampusCompassError(failure.message)),
        (presences) {
          final online = presences.where((p) => p.status == 'safe').toList();
          final alerts = presences.where((p) => p.status == 'sos').toList();
          
          // 4. Check Proximity
          String? proximityMessage;
          for (var alert in alerts) {
            double distance = Geolocator.distanceBetween(
              position.latitude, 
              position.longitude, 
              alert.latitude, 
              alert.longitude
            );
            
            if (distance < 100) {
              proximityMessage = "DANGER! SOS active ${distance.toStringAsFixed(0)}m away!";
              break; // Prioritize closest or first found
            }
          }

          // 5. Mock Danger Zones for Demo (Relative to user so they are visible)
          // In real app, fetch from repository.getZones()
          List<Zone> mockZones = [
            Zone(
              id: 'z1',
              name: 'Construction Site',
              description: 'Active construction work. Falling debris risk.',
              coordinates: [
                LatLng(position.latitude + 0.001, position.longitude + 0.001),
                LatLng(position.latitude + 0.002, position.longitude + 0.001),
                LatLng(position.latitude + 0.002, position.longitude + 0.002),
                LatLng(position.latitude + 0.001, position.longitude + 0.002),
              ],
              riskLevel: 'High',
              message: 'Warning: Entering Construction Zone',
            ),
             Zone(
              id: 'z2',
              name: 'Unlit Path',
              description: 'Street lights are out.',
              coordinates: [
                LatLng(position.latitude - 0.001, position.longitude - 0.001),
                LatLng(position.latitude - 0.0015, position.longitude - 0.0015),
                LatLng(position.latitude - 0.001, position.longitude - 0.002),
              ],
              riskLevel: 'Medium',
              message: 'Caution: Low visibility area',
            )
          ];

          emit(CampusCompassActive(
            onlineUsers: online,
            activeAlerts: alerts,
            dangerZones: mockZones,
            nearbyAlertMessage: proximityMessage,
          ));
        },
      );
    } catch (e) {
      // Geolocator error or other
      // emit(CampusCompassError(e.toString())); // Optional: don't break loop on single error
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
