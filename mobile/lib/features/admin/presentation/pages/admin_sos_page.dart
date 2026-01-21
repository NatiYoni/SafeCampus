import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/admin_sos_bloc.dart';
import '../bloc/admin_sos_event.dart';
import '../bloc/admin_sos_state.dart';
import 'package:intl/intl.dart';

class AdminSosPage extends StatelessWidget {
  const AdminSosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AdminSosBloc>()..add(LoadAdminSos()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Monitor SOS Alerts')),
        body: BlocBuilder<AdminSosBloc, AdminSosState>(
          builder: (context, state) {
            if (state is AdminSosLoading) {
               return const Center(child: CircularProgressIndicator());
            } else if (state is AdminSosLoaded) {
               if (state.alerts.isEmpty) {
                 return const Center(child: Text("No Active Alerts"));
               }
               return ListView.builder(
                 itemCount: state.alerts.length,
                 itemBuilder: (context, index) {
                   final alert = state.alerts[index];
                   return Card(
                     color: Colors.red.shade50,
                     margin: const EdgeInsets.all(8),
                     child: ListTile(
                       leading: const Icon(Icons.warning, color: Colors.red, size: 40),
                       title: Text("SOS Alert"),
                       subtitle: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text("User: ${alert.userName ?? 'Unknown'}"),
                           Text("Uni ID: ${alert.universityId ?? 'Unknown'} (ID: ${alert.userId})"),
                           Text("Location: ${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}"),
                           Text("Time: ${DateFormat.yMMMd().add_jm().format(alert.timestamp.toLocal())}"),
                         ],
                       ),
                       isThreeLine: true,
                     ),
                   );
                 },
               );
            } else if (state is AdminSosError) {
               return Center(child: Text("Error: ${state.message}"));
            }
            return const Center(child: Text('Live SOS feed will appear here'));
          },
        ),
      ),
    );
  }
}
