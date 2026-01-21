import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/trigger_sos.dart';
import '../../domain/usecases/cancel_sos.dart';
import '../../domain/usecases/get_my_active_alert.dart';
import 'emergency_event.dart';
import 'emergency_state.dart';

class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  final TriggerSos triggerSos;
  final CancelSos cancelSos;
  final GetMyActiveAlert getMyActiveAlert;

  EmergencyBloc({
    required this.triggerSos,
    required this.cancelSos,
    required this.getMyActiveAlert,
  }) : super(EmergencyInitial()) {
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

    on<SosStateChanged>((event, emit) {
      emit(SosTriggered(event.alert));
    });

    on<CheckEmergencyStatus>((event, emit) async {
      final result = await getMyActiveAlert(NoParams());
      result.fold(
        (failure) {}, // Do nothing on failure, assume no active alert or wait for user action
        (alert) {
          if (alert != null) {
            emit(SosTriggered(alert));
          }
        },
      );
    });
  }
}
