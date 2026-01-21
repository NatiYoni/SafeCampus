import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/email_verification_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/registration_screen.dart';
import 'features/auth/presentation/pages/welcome_screen.dart';
import 'features/emergency/presentation/bloc/emergency_bloc.dart';
import 'features/emergency/presentation/pages/dashboard_page.dart';
import 'features/friend_walk/presentation/bloc/friend_walk_bloc.dart';
import 'features/friend_walk/presentation/pages/friend_walk_page.dart';
import 'features/mental_health/presentation/bloc/mental_health_bloc.dart';
import 'features/mental_health/presentation/pages/mental_health_page.dart';
import 'features/reporting/presentation/bloc/reporting_bloc.dart';
import 'features/reporting/presentation/pages/report_page.dart';
import 'features/safety_timer/presentation/bloc/safety_timer_bloc.dart';
import 'features/safety_timer/presentation/pages/safety_timer_page.dart';
import 'features/admin/presentation/pages/admin_dashboard_page.dart';
import 'features/admin/presentation/pages/admin_sos_page.dart';
import 'features/admin/presentation/pages/admin_reports_page.dart';
import 'features/admin/presentation/pages/admin_walks_page.dart';
import 'features/admin/presentation/pages/admin_staff_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<EmergencyBloc>()),
        BlocProvider(create: (_) => di.sl<FriendWalkBloc>()),
        BlocProvider(create: (_) => di.sl<ReportingBloc>()),
        BlocProvider(create: (_) => di.sl<SafetyTimerBloc>()),
        BlocProvider(create: (_) => di.sl<MentalHealthBloc>()),
      ],
      child: MaterialApp.router(
        title: 'SafeCampus',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          primaryColor: const Color(0xFF5C6BC0), // Indigo 400
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
          textTheme: GoogleFonts.poppinsTextTheme(),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5C6BC0),
            secondary: const Color(0xFF26A69A), // Teal 400
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 1.5),
            ),
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}

// Simple Home Screen Placeholder
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SafeCampus Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to SafeCampus!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(LogoutEvent());
                context.go('/');
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/verify_email',
      builder: (context, state) {
        final email = state.extra as String;
        return EmailVerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: '/friend-walk',
      builder: (context, state) => const FriendWalkPage(),
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) => const ReportPage(),
    ),
    GoRoute(
      path: '/safety-timer',
      builder: (context, state) => const SafetyTimerPage(),
    ),
    GoRoute(
      path: '/mental-health',
      builder: (context, state) => const MentalHealthPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    // Admin Routes
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/admin/sos',
      builder: (context, state) => const AdminSosPage(),
    ),
    GoRoute(
      path: '/admin/reports',
      builder: (context, state) => const AdminReportsPage(),
    ),
    GoRoute(
      path: '/admin/walks',
      builder: (context, state) => const AdminWalksPage(),
    ),
    GoRoute(
      path: '/admin/staff',
      builder: (context, state) => const AdminStaffPage(),
    ),
  ],
);
