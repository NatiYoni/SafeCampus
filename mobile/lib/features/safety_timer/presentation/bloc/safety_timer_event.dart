import 'package:equatable/equatable.dart';
import '../../domain/entities/safety_timer.dart';

abstract class SafetyTimerEvent extends Equatable {
  const SafetyTimerEvent();
  @override
  List<Object> get props => [];
}

class TimerStarted extends SafetyTimerEvent {
  final String userId;
  final int durationMinutes;
  final List<String> guardians;

  const TimerStarted({required this.userId, required this.durationMinutes, required this.guardians});
  @override
  List<Object> get props => [userId, durationMinutes, guardians];
}

class TimerCancelled extends SafetyTimerEvent {}

class TimerTick extends SafetyTimerEvent {
  final int remainingSeconds;
  const TimerTick(this.remainingSeconds);
  @override
  List<Object> get props => [remainingSeconds];
}

class TimerExpiredEvent extends SafetyTimerEvent {}
