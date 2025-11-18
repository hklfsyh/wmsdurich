// lib/features/home/presentation/home_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/core/constants/asset_paths.dart';

// Mapping Index ke Path GoRouter
const List<String> homeShellRoutes = [
  '/home',
  '/home/warehouse',
  '/home/sales'
];

class HomeShell extends StatelessWidget {
  // GoRouter akan otomatis memberikan child (sub-route) yang sedang aktif di sini
  final Widget child;
  const HomeShell({super.key, required this.child});

  // Fungsi untuk menentukan index BottomNavBar berdasarkan path URL saat ini
  int _calculateSelectedIndex(BuildContext context) {
    // Dapatkan path URL saat ini (misal: /home/warehouse)
    final String location = GoRouterState.of(context).fullPath ?? '/home';

    // Temukan index path tersebut dalam daftar homeShellRoutes
    return homeShellRoutes.indexOf(location);
  }

  // Fungsi yang dipanggil ketika item BottomNavBar diklik
  void _onItemTapped(BuildContext context, int index) {
    // Navigasi menggunakan GoRouter ke path yang sesuai
    context.go(homeShellRoutes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(context, index),

        // 1. Styling Warna
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.inactiveGray,

        // Atur label ke always show
        showUnselectedLabels: true,

        items: [
          // Home
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 0 ? AssetPaths.homeBlack : AssetPaths.homeGray,
              height: 24,
            ),
            label: 'Home',
          ),
          // Warehouse
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 1 ? AssetPaths.boxBlack : AssetPaths.boxGray,
              height: 24,
            ),
            label: 'Warehouse',
          ),
          // Sales
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 2 ? AssetPaths.salesBlack : AssetPaths.salesGray,
              height: 24,
            ),
            label: 'Sales',
          ),
        ],
      ),
    );
  }
}
