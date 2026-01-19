import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/safety_timer_bloc.dart';
import '../bloc/safety_timer_event.dart';
import '../bloc/safety_timer_state.dart';

class SafetyTimerPage extends StatefulWidget {
  const SafetyTimerPage({super.key});

  @override
  State<SafetyTimerPage> createState() => _SafetyTimerPageState();
}

class _SafetyTimerPageState extends State<SafetyTimerPage> {
  int _selectedDuration = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Timer')),
      body: BlocBuilder<SafetyTimerBloc, SafetyTimerState>(
        builder: (context, state) {
          if (state is SafetyTimerRunning) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(state.remainingSeconds),
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Virtual Guardian Active', style: TextStyle(color: Colors.green)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SafetyTimerBloc>().add(TimerCancelled());
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('I\'m Safe (Cancel Timer)'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 const Text("Set a timer for your journey. If you don't check in before it ends, your guardians will be notified."),
                 const SizedBox(height: 32),
                 const Text("Duration (minutes):"),
                 Slider(
                   value: _selectedDuration.toDouble(),
                   min: 5,
                   max: 120,
                   divisions: 23,
                   label: _selectedDuration.toString(),
                   onChanged: (val) => setState(() => _selectedDuration = val.toInt()),
                 ),
                 Text("$_selectedDuration minutes", style: const TextStyle(fontSize: 24), textAlign: TextAlign.center),
                 const Spacer(),
                 ElevatedButton(
                   onPressed: () {
                     // TODO: Replace with real User ID
                     context.read<SafetyTimerBloc>().add(
                       TimerStarted(userId: "user-123", durationMinutes: _selectedDuration, guardians: const [])
                     );
                   },
                   child: const Text("Start Safety Timer"),
                 )
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
