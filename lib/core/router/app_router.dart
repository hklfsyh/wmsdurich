import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Placeholder Pages (Kita akan ganti ini nanti)
import 'package:wms_durich/features/auth/presentation/splash_screen.dart';
import 'package:wms_durich/features/auth/presentation/login_page.dart';
import 'package:wms_durich/features/home/presentation/home_page.dart';
import 'package:wms_durich/features/warehouse/presentation/warehouse_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // TODO: Tambahkan logic pengalihan ke Login/Home berdasarkan status token
  // String initialRoute = '/splash';

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
          routes: [
            // Sub-route untuk navigasi Bottom Bar (Warehouse, Sales)
            GoRoute(
              path: 'warehouse',
              builder: (context, state) => const WarehousePage(),
            ),
            // TODO: Tambahkan rute untuk /home/sales, /home/add_data, dll.
          ]),
      // Tambahkan rute lain di sini (misalnya untuk Edit Data, Add Pengiriman)
    ],
    // Handle error jika rute tidak ditemukan
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
    ),
  );
});
