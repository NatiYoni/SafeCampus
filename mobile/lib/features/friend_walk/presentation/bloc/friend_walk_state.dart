import 'package:equatable/equatable.dart';
import '../../domain/entities/walk_session.dart';

abstract class FriendWalkState extends Equatable {
  const FriendWalkState();
  @override
  List<Object?> get props => [];
}

class FriendWalkInitial extends FriendWalkState {}
class FriendWalkLoading extends FriendWalkState {}
class FriendWalkActive extends FriendWalkState {
  final WalkSession session;
  const FriendWalkActive(this.session);
  @override
  List<Object> get props => [session];
}
class FriendWalkError extends FriendWalkState {
  final String message;
  const FriendWalkError(this.message);
  @override
  List<Object> get props => [message];
}
