import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../injection_container.dart' as di;
import '../../../../features/reporting/presentation/bloc/reporting_bloc.dart';
import '../../../../features/reporting/presentation/bloc/reporting_event.dart';
import '../../../../features/reporting/presentation/bloc/reporting_state.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ReportingBloc>()..add(FetchReportsRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Hazard Reports')),
        body: BlocBuilder<ReportingBloc, ReportingState>(
          builder: (context, state) {
            if (state is ReportingLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ReportsLoaded) {
              if (state.reports.isEmpty) {
                return const Center(child: Text("No active reports found."));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.reports.length,
                itemBuilder: (context, index) {
                  final report = state.reports[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Category (Type) and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  report.category,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(report.status, style: const TextStyle(fontSize: 10)),
                                backgroundColor: report.status == "Reviewed" 
                                    ? Colors.green[100] 
                                    : Colors.amber[100],
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Message
                          Text(
                            report.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          // Bottom Row: Timestamp and Name (if not anonymous)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                report.timestamp.toString().substring(0, 16),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              if (!report.isAnonymous && report.userName != null)
                                Text(
                                  "Reported by: ${report.userName}", 
                                  style: const TextStyle(
                                    fontSize: 12, 
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is ReportingError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Initializing...'));
          },
        ),
      ),
    );
  }
}
