import 'package:equatable/equatable.dart';

abstract class AdminWalksEvent extends Equatable {
  const AdminWalksEvent();

  @override
  List<Object> get props => [];
}

class FetchActiveWalks extends AdminWalksEvent {}
