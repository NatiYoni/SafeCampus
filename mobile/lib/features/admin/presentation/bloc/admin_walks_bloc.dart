import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../friend_walk/domain/usecases/get_all_active_walks.dart';
import 'admin_walks_event.dart';
import 'admin_walks_state.dart';

class AdminWalksBloc extends Bloc<AdminWalksEvent, AdminWalksState> {
  final GetAllActiveWalks getAllActiveWalks;
  Timer? _timer;

  AdminWalksBloc({required this.getAllActiveWalks}) : super(AdminWalksInitial()) {
    on<FetchActiveWalks>(_onFetchActiveWalks);
    
    // Auto refresh every 5 seconds for live tracking
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      add(FetchActiveWalks());
    });
  }

  Future<void> _onFetchActiveWalks(FetchActiveWalks event, Emitter<AdminWalksState> emit) async {
    // Only emit loading on first load if we want smooth updates, 
    // but for now let's just keep it simple. Maybe avoid full loading spinner for refresh.
    if (state is AdminWalksInitial) {
      emit(AdminWalksLoading());
    }
    
    final result = await getAllActiveWalks(NoParams());
    
    result.fold(
      (failure) => emit(AdminWalksError(failure.message)),
      (walks) => emit(AdminWalksLoaded(walks)),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
