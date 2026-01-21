import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../emergency/domain/usecases/get_alerts.dart';
import 'admin_sos_event.dart';
import 'admin_sos_state.dart';

class AdminSosBloc extends Bloc<AdminSosEvent, AdminSosState> {
  final GetAlerts getAlerts;

  AdminSosBloc({required this.getAlerts}) : super(AdminSosInitial()) {
    on<LoadAdminSos>((event, emit) async {
      emit(AdminSosLoading());
      final result = await getAlerts(NoParams());
      result.fold(
        (failure) => emit(AdminSosError(failure.message)),
        (alerts) => emit(AdminSosLoaded(alerts)),
      );
    });
  }
}
