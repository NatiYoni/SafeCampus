import 'package:equatable/equatable.dart';

abstract class EmergencyEvent extends Equatable {
  const EmergencyEvent();

  @override
  List<Object> get props => [];
}

class TriggerSosEvent extends EmergencyEvent {
  final String userId;

  const TriggerSosEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
