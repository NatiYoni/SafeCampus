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
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orangeAccent,
                        child: Text(report.category[0]),
                      ),
                      title: Text(
                        report.category,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(report.description),
                          const SizedBox(height: 4),
                          Text(
                            report.timestamp.toString().substring(0, 16),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(report.status),
                        backgroundColor: report.status == "Reviewed" 
                            ? Colors.green[100] 
                            : Colors.amber[100],
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
