import 'package:equatable/equatable.dart';
import '../../domain/entities/alert.dart';

abstract class EmergencyState extends Equatable {
  const EmergencyState();
  
  @override
  List<Object> get props => [];
}

class EmergencyInitial extends EmergencyState {}

class EmergencyLoading extends EmergencyState {}

class SosTriggered extends EmergencyState {
  final Alert alert;

  const SosTriggered(this.alert);

  @override
  List<Object> get props => [alert];
}

class EmergencyError extends EmergencyState {
  final String message;

  const EmergencyError(this.message);

  @override
  List<Object> get props => [message];
}
