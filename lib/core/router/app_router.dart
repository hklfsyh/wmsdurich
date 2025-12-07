import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wms_durich/features/auth/presentation/splash_screen.dart';
import 'package:wms_durich/features/auth/presentation/login_page.dart';
import 'package:wms_durich/features/auth/presentation/providers/auth_provider.dart';

import 'package:wms_durich/features/home/presentation/home_shell.dart';
import 'package:wms_durich/features/home/presentation/dashboard_page.dart';
import 'package:wms_durich/features/warehouse/presentation/warehouse_page.dart';
import 'package:wms_durich/features/warehouse/presentation/list_buah_page.dart';
import 'package:wms_durich/features/sales/presentation/sales_page.dart';
import 'package:wms_durich/features/settings/presentation/pages/settings_page.dart';

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeInOut;
      var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: curve),
      );
      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final user = authState.user;
      final path = state.fullPath ?? '';

      // Jangan redirect di splash dan login
      if (path == '/splash' || path == '/login') {
        return null;
      }

      // Jika belum login, redirect ke login
      if (user == null) {
        return '/login';
      }

      // Role-based access control
      final isAdmin = user.isAdmin;
      final isWarehouse = user.isWarehouse;
      final isSales = user.isSales;

      // Admin bisa akses semua page
      if (isAdmin) {
        return null;
      }

      // Warehouse hanya bisa akses /home/warehouse
      if (isWarehouse && !path.startsWith('/home/warehouse') && path != '/settings') {
        return '/home/warehouse';
      }

      // Sales hanya bisa akses /home/sales
      if (isSales && !path.startsWith('/home/sales') && path != '/settings') {
        return '/home/sales';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const SettingsPage(),
        ),
      ),
      ShellRoute(
        pageBuilder: (context, state, child) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: HomeShell(child: child),
        ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/home/warehouse',
            builder: (context, state) => const WarehousePage(),
          ),
          GoRoute(
            path: '/home/warehouse/list-buah',
            builder: (context, state) => const ListBuahPage(),
          ),
          GoRoute(
            path: '/home/sales',
            builder: (context, state) => const SalesPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
    ),
  );
});
