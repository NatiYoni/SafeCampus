import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Import go_router for navigation
import '../bloc/safety_timer_bloc.dart';
import '../bloc/safety_timer_event.dart';
import '../bloc/safety_timer_state.dart';

class SafetyTimerPage extends StatefulWidget {
  const SafetyTimerPage({super.key});

  @override
  State<SafetyTimerPage> createState() => _SafetyTimerPageState();
}

class _SafetyTimerPageState extends State<SafetyTimerPage> {
  int _selectedDuration = 15; // Default 15 mins

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Timer')),
      body: BlocConsumer<SafetyTimerBloc, SafetyTimerState>(
        listener: (context, state) {
          if (state is SafetyTimerError) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is SafetyTimerRunning) {
            return _buildRunningTimer(context, state);
          }
          return _buildSetupTimer(context);
        },
      ),
    );
  }

  Widget _buildSetupTimer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text("Set a timer for your walk.", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedDuration,
            items: [5, 10, 15, 30, 60].map((e) => DropdownMenuItem(value: e, child: Text("$e minutes"))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedDuration = val);
            },
            decoration: const InputDecoration(labelText: 'Duration'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<SafetyTimerBloc>().add(TimerStarted(
                  userId: "me",
                  durationMinutes: _selectedDuration,
                  guardians: const [], // Add guardians logic later
                ));
              },
              child: const Text('Start Timer'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRunningTimer(BuildContext context, SafetyTimerRunning state) {
    final minutes = (state.remainingSeconds / 60).floor();
    final seconds = state.remainingSeconds % 60;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           const Text("Timer Running", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
           const SizedBox(height: 20),
           Text(
             "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
             style: const TextStyle(fontSize: 60, fontFamily: 'monospace'),
           ),
           const SizedBox(height: 40),
           ElevatedButton(
             style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
             onPressed: () {
                context.read<SafetyTimerBloc>().add(TimerCancelled());
             },
             child: const Text('I\'m Safe (Cancel Timer)'),
           )
        ],
      ),
    );
  }
}
