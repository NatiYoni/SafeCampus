import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/trigger_sos.dart';
import 'emergency_event.dart';
import 'emergency_state.dart';

class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  final TriggerSos triggerSos;

  EmergencyBloc({required this.triggerSos}) : super(EmergencyInitial()) {
    on<TriggerSosEvent>((event, emit) async {
      emit(EmergencyLoading());
      final result = await triggerSos(event.userId);
      result.fold(
        (failure) => emit(EmergencyError(failure.message)),
        (alert) => emit(SosTriggered(alert)),
      );
    });
  }
}
