import 'package:equatable/equatable.dart';
import '../../domain/entities/safety_timer.dart';

abstract class SafetyTimerState extends Equatable {
  const SafetyTimerState();
  @override
  List<Object?> get props => [];
}

class SafetyTimerInitial extends SafetyTimerState {}
class SafetyTimerRunning extends SafetyTimerState {
  final SafetyTimer timer;
  final int remainingSeconds;
  const SafetyTimerRunning(this.timer, this.remainingSeconds);
  @override
  List<Object> get props => [timer, remainingSeconds];
}
class SafetyTimerError extends SafetyTimerState {
  final String message;
  const SafetyTimerError(this.message);
  @override
  List<Object> get props => [message];
}
