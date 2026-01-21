import 'package:equatable/equatable.dart';
import '../../domain/entities/mental_health_resource.dart';

abstract class MentalHealthState extends Equatable {
  const MentalHealthState();
  @override
  List<Object> get props => [];
}

class MentalHealthInitial extends MentalHealthState {}
class MentalHealthLoading extends MentalHealthState {}
class MentalHealthLoaded extends MentalHealthState {
  final List<MentalHealthResource> resources;
  const MentalHealthLoaded(this.resources);
  @override
  List<Object> get props => [resources];
}
class MentalHealthError extends MentalHealthState {
  final String message;
  const MentalHealthError(this.message);
  @override
  List<Object> get props => [message];
}
