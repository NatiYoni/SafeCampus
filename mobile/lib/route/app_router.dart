import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/emergency/presentation/pages/dashboard_page.dart';
import '../../features/friend_walk/presentation/pages/friend_walk_page.dart';
import '../../features/reporting/presentation/pages/reporting_page.dart';
import '../../features/safety_timer/presentation/pages/safety_timer_page.dart';

final goRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/friend-walk',
      builder: (context, state) => const FriendWalkPage(),
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) => const ReportingPage(),
    ),
    GoRoute(
      path: '/safety-timer',
      builder: (context, state) => const SafetyTimerPage(),
    ),
  ],
);
