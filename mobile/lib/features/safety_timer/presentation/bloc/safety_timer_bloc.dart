import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/set_timer.dart';
import '../../domain/usecases/cancel_timer.dart';
import '../../../emergency/domain/usecases/trigger_sos.dart';
import 'safety_timer_event.dart';
import 'safety_timer_state.dart';

class SafetyTimerBloc extends Bloc<SafetyTimerEvent, SafetyTimerState> {
  final SetTimer setTimer;
  final CancelTimer cancelTimer;
  final TriggerSos triggerSos;
  Timer? _ticker;

  SafetyTimerBloc({
    required this.setTimer, 
    required this.cancelTimer,
    required this.triggerSos,
  }) : super(SafetyTimerInitial()) {
    on<TimerStarted>((event, emit) async {
      final result = await setTimer(SetTimerParams(
        userId: event.userId,
        durationMinutes: event.durationMinutes,
        guardians: event.guardians,
      ));

      result.fold(
        (failure) => emit(SafetyTimerError(failure.message)),
        (timer) {
          _startTicker(event.durationMinutes * 60);
          emit(SafetyTimerRunning(timer, event.durationMinutes * 60));
        },
      );
    });

    on<TimerTick>((event, emit) {
      if (state is SafetyTimerRunning) {
        emit(SafetyTimerRunning((state as SafetyTimerRunning).timer, event.remainingSeconds));
      }
    });

    on<TimerCancelled>((event, emit) async {
      _ticker?.cancel();
      if (state is SafetyTimerRunning) {
        final timerId = (state as SafetyTimerRunning).timer.id;
        await cancelTimer(timerId);
      }
      emit(SafetyTimerInitial());
    });

    on<TimerExpiredEvent>((event, emit) async {
      if (state is SafetyTimerRunning) {
        final userId = (state as SafetyTimerRunning).timer.userId;
        await triggerSos(userId);
      }
    });
  }

  void _startTicker(int durationSeconds) {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = durationSeconds - timer.tick;
      if (remaining < 0) {
        timer.cancel();
        add(TimerExpiredEvent());
      } else {
        add(TimerTick(remaining));
      }
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
