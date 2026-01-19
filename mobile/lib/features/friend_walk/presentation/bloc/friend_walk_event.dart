import 'package:equatable/equatable.dart';
import '../../domain/entities/walk_session.dart';

abstract class FriendWalkEvent extends Equatable {
  const FriendWalkEvent();
  @override
  List<Object> get props => [];
}

class StartWalkRequested extends FriendWalkEvent {
  final String userId;
  final String guardianId;
  const StartWalkRequested(this.userId, this.guardianId);
  @override
  List<Object> get props => [userId, guardianId];
}

class LocationUpdated extends FriendWalkEvent {
  final double lat;
  final double lng;
  const LocationUpdated(this.lat, this.lng);
  @override
  List<Object> get props => [lat, lng];
}

class EndWalkRequested extends FriendWalkEvent {
  const EndWalkRequested();
}
