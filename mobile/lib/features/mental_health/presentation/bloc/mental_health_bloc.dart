import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_mental_health_resources.dart';
import 'mental_health_event.dart';
import 'mental_health_state.dart';

class MentalHealthBloc extends Bloc<MentalHealthEvent, MentalHealthState> {
  final GetMentalHealthResources getResources;

  MentalHealthBloc({required this.getResources}) : super(MentalHealthInitial()) {
    on<LoadMentalHealthResources>((event, emit) async {
      emit(MentalHealthLoading());
      final result = await getResources(NoParams());
      result.fold(
        (failure) => emit(MentalHealthError(failure.message)),
        (resources) => emit(MentalHealthLoaded(resources)),
      );
    });
  }
}
