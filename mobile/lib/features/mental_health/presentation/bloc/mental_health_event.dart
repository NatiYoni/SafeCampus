import 'package:equatable/equatable.dart';

abstract class MentalHealthEvent extends Equatable {
  const MentalHealthEvent();
  @override
  List<Object> get props => [];
}

class LoadMentalHealthResources extends MentalHealthEvent {}
