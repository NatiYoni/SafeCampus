import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/submit_report.dart';
import 'reporting_event.dart';
import 'reporting_state.dart';

class ReportingBloc extends Bloc<ReportingEvent, ReportingState> {
  final SubmitReport submitReport;

  ReportingBloc({required this.submitReport}) : super(ReportingInitial()) {
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
  }
}
