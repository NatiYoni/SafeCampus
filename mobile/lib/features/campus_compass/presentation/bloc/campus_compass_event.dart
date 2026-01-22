import 'package:equatable/equatable.dart';

abstract class CampusCompassEvent extends Equatable {
  const CampusCompassEvent();
  @override
  List<Object> get props => [];
}

class StartRadar extends CampusCompassEvent {}
class StopRadar extends CampusCompassEvent {}
class RefreshRadar extends CampusCompassEvent {}
