import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/submit_report.dart';
import '../../domain/usecases/get_reports.dart';
import 'reporting_event.dart';
import 'reporting_state.dart';

class ReportingBloc extends Bloc<ReportingEvent, ReportingState> {
  final SubmitReport submitReport;
  final GetReports getReports; // Add fetch usecase

  ReportingBloc({
    required this.submitReport,
    required this.getReports,
  }) : super(ReportingInitial()) {
    on<SubmitReportRequested>((event, emit) async {
      emit(ReportingLoading());
      final result = await submitReport(SubmitReportParams(
        userId: event.userId,
        category: event.category,
        description: event.description,
        isAnonymous: event.isAnonymous,
      ));
      result.fold(
        (failure) => emit(ReportingError(failure.message)),
        (report) => emit(ReportingSuccess(report)),
      );
    });

    on<FetchReportsRequested>((event, emit) async {
      emit(ReportingLoading());
      final result = await getReports(NoParams());
      result.fold(
        (failure) => emit(ReportingError(failure.message)),
        (reports) => emit(ReportsLoaded(reports)),
      );
    });
  }
}
