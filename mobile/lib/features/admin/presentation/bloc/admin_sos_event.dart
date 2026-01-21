import 'package:equatable/equatable.dart';

abstract class AdminSosEvent extends Equatable {
  const AdminSosEvent();
  @override
  List<Object> get props => [];
}

class LoadAdminSos extends AdminSosEvent {}
