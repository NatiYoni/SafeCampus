import 'package:equatable/equatable.dart';
import '../../domain/entities/campus_presence.dart';
import '../../domain/entities/zone.dart';

abstract class CampusCompassState extends Equatable {
  const CampusCompassState();
  @override
  List<Object> get props => [];
}

class CampusCompassInitial extends CampusCompassState {}
class CampusCompassLoading extends CampusCompassState {}
class CampusCompassActive extends CampusCompassState {
  final List<CampusPresence> onlineUsers;
  final List<CampusPresence> activeAlerts;
  final List<Zone> dangerZones;
  final String? nearbyAlertMessage;

  const CampusCompassActive({
    required this.onlineUsers,
    required this.activeAlerts,
    this.dangerZones = const [],
    this.nearbyAlertMessage,
  });

  @override
  List<Object> get props => [onlineUsers, activeAlerts, dangerZones, nearbyAlertMessage ?? ''];
}
class CampusCompassError extends CampusCompassState {
  final String message;
  const CampusCompassError(this.message);
  @override
  List<Object> get props => [message];
}
