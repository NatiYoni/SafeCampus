import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/start_walk.dart';
import 'friend_walk_event.dart';
import 'friend_walk_state.dart';

class FriendWalkBloc extends Bloc<FriendWalkEvent, FriendWalkState> {
  final StartWalk startWalk;
  String? currentWalkId;

  FriendWalkBloc({required this.startWalk}) : super(FriendWalkInitial()) {
    on<StartWalkRequested>((event, emit) async {
      emit(FriendWalkLoading());
      final result = await startWalk(StartWalkParams(userId: event.userId, guardianId: event.guardianId));
      result.fold(
        (failure) => emit(FriendWalkError(failure.message)),
        (session) {
          currentWalkId = session.id;
          emit(FriendWalkActive(session));
        },
      );
    });

    on<LocationUpdated>((event, emit) {
      if (state is FriendWalkActive && currentWalkId != null) {
        // Here we would call updateLocation use case
        // For now, just keep state active
      }
    });

    on<EndWalkRequested>((event, emit) {
       currentWalkId = null;
       emit(FriendWalkInitial());
    });
  }
}
