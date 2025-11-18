// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Placeholder Pages (Tetap digunakan)
import 'package:wms_durich/features/auth/presentation/splash_screen.dart';
import 'package:wms_durich/features/auth/presentation/login_page.dart';

// Import Class Shell dan Page yang telah diubah namanya
import 'package:wms_durich/features/home/presentation/home_shell.dart'; // 👈 HOME SHELL BARU
import 'package:wms_durich/features/home/presentation/dashboard_page.dart'; // 👈 DASHBOARD PAGE BARU
import 'package:wms_durich/features/warehouse/presentation/warehouse_page.dart';
import 'package:wms_durich/features/sales/presentation/sales_page.dart';

// Fungsi untuk membuat transisi halaman yang halus (Fade Transition)
CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Menggunakan Fade Transition (transparansi)
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration:
        const Duration(milliseconds: 500), // Durasi transisi 0.5 detik
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  // TODO: Tambahkan logic pengalihan ke Login/Home berdasarkan status token

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        // MENGGUNAKAN pageBuilder DENGAN TRANSISI KUSTOM
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        // MENGGUNAKAN pageBuilder DENGAN TRANSISI KUSTOM
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const LoginPage(),
        ),
      ),

      // 👇 SHELLROUTE UNTUK BOTTOM NAV BAR (MENGGANTIKAN GoRoute /home LAMA)
      ShellRoute(
        // ShellRoute menggunakan pageBuilder untuk menerapkan transisi ke Shell
        pageBuilder: (context, state, child) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: HomeShell(
              child: child), // child adalah sub-route yang sedang aktif
        ),
        routes: [
          // Sub-route 0: Dashboard (Home - path: /home)
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const DashboardPage(), // Konten Home/Dashboard
          ),
          // Sub-route 1: Warehouse (path: /home/warehouse)
          GoRoute(
            path: '/home/warehouse',
            builder: (context, state) =>
                const WarehousePage(), // Konten Warehouse List
          ),
          // Sub-route 2: Sales (path: /home/sales)
          GoRoute(
            path: '/home/sales',
            builder: (context, state) => const SalesPage(),
          ),
        ],
      ),
      // Tambahkan rute lain di sini (misalnya rute yang tidak menggunakan Bottom Nav Bar)
    ],
    // Handle error jika rute tidak ditemukan
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
    ),
  );
});
