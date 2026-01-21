import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/trigger_sos.dart';
import '../../domain/usecases/cancel_sos.dart';
import 'emergency_event.dart';
import 'emergency_state.dart';

class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  final TriggerSos triggerSos;
  final CancelSos cancelSos;

  EmergencyBloc({required this.triggerSos, required this.cancelSos}) : super(EmergencyInitial()) {
    on<TriggerSosEvent>((event, emit) async {
      emit(EmergencyLoading());
      final result = await triggerSos(event.userId);
      result.fold(
        (failure) => emit(EmergencyError(failure.message)),
        (alert) => emit(SosTriggered(alert)),
      );
    });

    on<CancelSosEvent>((event, emit) async {
      emit(EmergencyLoading());
      final result = await cancelSos(event.alertId);
      result.fold(
        (failure) => emit(EmergencyError(failure.message)),
        (_) => emit(EmergencyInitial()), // Reset to initial state after cancelling
      );
    });
  }
}
