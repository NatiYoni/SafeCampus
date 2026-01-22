import 'package:equatable/equatable.dart';
import '../../../friend_walk/domain/entities/walk_session.dart';

abstract class AdminWalksState extends Equatable {
  const AdminWalksState();
  
  @override
  List<Object> get props => [];
}

class AdminWalksInitial extends AdminWalksState {}

class AdminWalksLoading extends AdminWalksState {}

class AdminWalksLoaded extends AdminWalksState {
  final List<WalkSession> activeWalks;

  const AdminWalksLoaded(this.activeWalks);

  @override
  List<Object> get props => [activeWalks];
}

class AdminWalksError extends AdminWalksState {
  final String message;

  const AdminWalksError(this.message);

  @override
  List<Object> get props => [message];
}
