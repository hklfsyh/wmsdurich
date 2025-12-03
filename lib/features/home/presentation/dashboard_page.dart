import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/core/widgets/profile_dropdown.dart';
import 'package:wms_durich/features/home/data/home_repository.dart';
import 'package:wms_durich/features/home/presentation/widgets/warehouse_summary_card.dart';
import 'package:wms_durich/features/home/presentation/widgets/sales_summary_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gunakan AsyncValue dari Riverpod untuk memantau data Dashboard
    final dashboardAsyncValue = ref.watch(dashboardDataProvider);

    return Scaffold(
      // Tambahkan AppBar di sini
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Warehouse Management'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.shade300, width: 0.5),
              ),
              child: Text(
                'DEMO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
          ],
        ),
        // Hilangkan tombol back karena ini adalah root tab
        automaticallyImplyLeading: false,
        actions: [
          const ProfileDropdown(),
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
