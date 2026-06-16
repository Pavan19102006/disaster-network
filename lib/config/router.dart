import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/sos/sos_screen.dart';
import '../screens/alerts/alerts_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/peers/peers_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/bottom_nav_shell.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _buildPage(
              state,
              const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/map',
            pageBuilder: (context, state) => _buildPage(
              state,
              const MapScreen(),
            ),
          ),
          GoRoute(
            path: '/sos',
            pageBuilder: (context, state) => _buildPage(
              state,
              const SOSScreen(),
            ),
          ),
          GoRoute(
            path: '/alerts',
            pageBuilder: (context, state) => _buildPage(
              state,
              const AlertsScreen(),
            ),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) => _buildPage(
              state,
              const ChatScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/peers',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildPage(
          state,
          const PeersScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildPage(
          state,
          const SettingsScreen(),
        ),
      ),
    ],
  );

  static CustomTransitionPage _buildPage(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
