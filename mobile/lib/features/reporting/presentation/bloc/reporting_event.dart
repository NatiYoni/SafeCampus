import 'package:equatable/equatable.dart';
import '../../domain/entities/report.dart';

abstract class ReportingEvent extends Equatable {
  const ReportingEvent();
  @override
  List<Object> get props => [];
}

class SubmitReportRequested extends ReportingEvent {
  final String userId;
  final String category;
  final String description;
  final bool isAnonymous;

  const SubmitReportRequested({
    required this.userId,
    required this.category,
    required this.description,
    required this.isAnonymous,
  });

  @override
  List<Object> get props => [userId, category, description, isAnonymous];
}
