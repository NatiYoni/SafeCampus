import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'route/app_router.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/emergency/presentation/bloc/emergency_bloc.dart';
import 'features/friend_walk/presentation/bloc/friend_walk_bloc.dart';
import 'features/reporting/presentation/bloc/reporting_bloc.dart';
import 'features/safety_timer/presentation/bloc/safety_timer_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const SafeCampusApp());
}

class SafeCampusApp extends StatelessWidget {
  const SafeCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<EmergencyBloc>(create: (_) => di.sl<EmergencyBloc>()),
        BlocProvider<FriendWalkBloc>(create: (_) => di.sl<FriendWalkBloc>()),
        BlocProvider<ReportingBloc>(create: (_) => di.sl<ReportingBloc>()),
        BlocProvider<SafetyTimerBloc>(create: (_) => di.sl<SafetyTimerBloc>()),
        BlocProvider<ChatBloc>(create: (_) => di.sl<ChatBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Safe Campus',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: goRouter,
      ),
    );
  }
}
