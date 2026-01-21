import 'package:equatable/equatable.dart';
import '../../domain/entities/report.dart';

abstract class ReportingState extends Equatable {
  const ReportingState();
  @override
  List<Object> get props => [];
}

class ReportingInitial extends ReportingState {}
class ReportingLoading extends ReportingState {}
class ReportingSuccess extends ReportingState {
  final Report report;
  const ReportingSuccess(this.report);
  @override
  List<Object> get props => [report];
}
class ReportingError extends ReportingState {
  final String message;
  const ReportingError(this.message);
  @override
  List<Object> get props => [message];
}

class ReportsLoaded extends ReportingState {
  final List<Report> reports;
  const ReportsLoaded(this.reports);
  @override
  List<Object> get props => [reports];
}
