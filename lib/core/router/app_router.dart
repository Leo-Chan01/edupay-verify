import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edupay_verify/features/auth/presentation/screens/login_screen.dart';
import 'package:edupay_verify/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:edupay_verify/features/dashboard/presentation/screens/home_screen.dart';
import 'package:edupay_verify/features/history/presentation/screens/history_screen.dart';
import 'package:edupay_verify/features/offline/presentation/screens/offline_screen.dart';
import 'package:edupay_verify/features/verification/presentation/screens/qr_scanner_screen.dart';
import 'package:edupay_verify/features/verification/presentation/screens/manual_search_screen.dart';
import 'package:edupay_verify/features/verification/presentation/screens/verification_result_screen.dart';
import 'package:edupay_verify/features/auth/providers/auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellHome',
);
final _shellNavigatorOfflineKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellOffline',
);
final _shellNavigatorHistoryKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellHistory',
);

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomeScreen()),
              ),
              GoRoute(
                path: '/qr-scanner',
                name: 'qr-scanner',
                builder: (context, state) => const QRScannerScreen(),
              ),
              GoRoute(
                path: '/manual-search',
                name: 'manual-search',
                builder: (context, state) => const ManualSearchScreen(),
              ),
              GoRoute(
                path: '/verification-result',
                name: 'verification-result',
                builder: (context, state) => const VerificationResultScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorOfflineKey,
            routes: [
              GoRoute(
                path: '/offline',
                name: 'offline',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: OfflineScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHistoryKey,
            routes: [
              GoRoute(
                path: '/history',
                name: 'history',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HistoryScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
