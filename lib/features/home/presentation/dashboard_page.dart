import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/auth/presentation/providers/auth_provider.dart';
import 'package:wms_durich/features/home/data/home_repository.dart';
import 'package:wms_durich/features/home/presentation/widgets/warehouse_summary_card.dart';
import 'package:wms_durich/features/home/presentation/widgets/sales_summary_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gunakan AsyncValue dari Riverpod untuk memantau data Dashboard
    final dashboardAsyncValue = ref.watch(dashboardDataProvider);
    
    // Untuk akses fungsi logout
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      // Tambahkan AppBar di sini
      appBar: AppBar(
        title: const Text('Warehouse Management'),
        // Hilangkan tombol back karena ini adalah root tab
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.fieldBackground,
              child: Icon(LucideIcons.user, color: AppColors.textPrimary, size: 20),
            ),
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onSelected: (value) async {
              if (value == 'settings') {
                context.push('/settings');
              } else if (value == 'logout') {
                await authNotifier.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
               const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(LucideIcons.settings, size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(LucideIcons.logOut, size: 18, color: AppColors.statusDangerDark),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: AppColors.statusDangerDark)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),

      // Menampilkan konten sesuai status data (Loading, Error, Data)
      body: dashboardAsyncValue.when(
        // 1. Loading State
        loading: () => const Center(child: CircularProgressIndicator()),

        // 2. Error State
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error memuat data dashboard: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.statusDangerDark),
            ),
          ),
        ),

        // 3. Data Loaded State
        data: (dashboardModel) {
          // Konten Dashboard yang sudah mendapatkan data dummy
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 1. Ringkasan Warehouse
                WarehouseSummaryCard(model: dashboardModel),
                const SizedBox(height: 24),

                // 2. Ringkasan Penjualan
                SalesSummaryCard(model: dashboardModel),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
