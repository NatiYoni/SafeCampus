import 'package:equatable/equatable.dart';
import '../../../emergency/domain/entities/alert.dart';

abstract class AdminSosState extends Equatable {
  const AdminSosState();
  @override
  List<Object> get props => [];
}

class AdminSosInitial extends AdminSosState {}

class AdminSosLoading extends AdminSosState {}

class AdminSosLoaded extends AdminSosState {
  final List<Alert> alerts;

  const AdminSosLoaded(this.alerts);

  @override
  List<Object> get props => [alerts];
}

class AdminSosError extends AdminSosState {
  final String message;

  const AdminSosError(this.message);

  @override
  List<Object> get props => [message];
}
