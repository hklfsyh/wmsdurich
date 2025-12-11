import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/core/widgets/profile_dropdown.dart';
import 'package:wms_durich/features/auth/presentation/providers/auth_provider.dart';
import 'package:wms_durich/features/warehouse/presentation/draft_lot_selection_page.dart';
import 'package:wms_durich/features/warehouse/presentation/list_buah_page.dart';
import 'package:wms_durich/features/warehouse/presentation/lot_stock_page.dart';
import 'package:wms_durich/features/warehouse/presentation/shipment_list_page.dart';
import 'package:wms_durich/features/warehouse/presentation/incoming_shipments_page.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/master_data_provider.dart';

class WarehousePage extends ConsumerWidget {
  const WarehousePage({super.key});

  void _showAddLotStockDialog(BuildContext context) {
    // Navigasi ke halaman pilihan draft lot (DraftLotSelectionPage)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DraftLotSelectionPage()),
    );
  }

  void _showShipmentListPage(BuildContext context, WidgetRef ref) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShipmentListPage()),
    );
    ref.invalidate(warehouseDataProvider);
  }

  void _showIncomingShipmentsPage(BuildContext context, WidgetRef ref) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IncomingShipmentsPage()),
    );
    ref.invalidate(warehouseDataProvider);
  }

  void _showLotStockPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LotStockPage()),
    );
  }

  void _showListBuahPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ListBuahPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouseDataAsync = ref.watch(warehouseDataProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    // Logika UI:
    // 1. User Cabang (Admin Cabang & Warehouse Cabang): Fokus menerima barang dari Pusat -> Tombol "Lot Sedang Dikirim"
    // 2. User Pusat (Admin Pusat & Warehouse Pusat): Fokus input stok/panen -> Tombol "Add Lot Stock"
    
    final isBranchUser = user?.isBranchUser ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Management'),
        automaticallyImplyLeading: false,
        actions: [
          const ProfileDropdown(),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Tombol berdasarkan role (Cabang vs Pusat)
            if (isBranchUser)
              // Tombol untuk Cabang (Admin & Warehouse): Lihat Pengiriman Masuk (Verify Incoming)
              ElevatedButton.icon(
                onPressed: () => _showIncomingShipmentsPage(context, ref),
                icon: const Icon(LucideIcons.packageCheck,
                    color: AppColors.white, size: 20),
                label: const Text('Lot Sedang Dikirim',
                    style: TextStyle(
                        color: AppColors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              )
            else
              // Tombol untuk Pusat (Admin & Warehouse): Add Lot Stock
              ElevatedButton.icon(
                onPressed: () => _showAddLotStockDialog(context),
                icon: const Icon(LucideIcons.package,
                    color: AppColors.white, size: 20),
                label: const Text('Add Lot Stock',
                    style: TextStyle(
                        color: AppColors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            const SizedBox(height: 24),

            // 2. List Item dengan Statistik
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.fieldBackground, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: warehouseDataAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.alertCircle,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('Gagal memuat data',
                            style: TextStyle(color: Colors.red[700])),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.refresh(warehouseDataProvider),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                  data: (data) => ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Item 1: Total Buah Masuk Hari Ini
                      InkWell(
                        onTap: () => _showListBuahPage(context),
                        borderRadius: BorderRadius.circular(8),
                        child: _buildStatCard(
                          icon: LucideIcons.truck,
                          iconColor: Colors.blue,
                          iconBgColor: Colors.blue.withOpacity(0.1),
                          title: 'Total Buah Masuk Hari Ini',
                          value: '${data.totalBuahRawToday} buah',
                          subtitle: 'Data akumulasi hari ini',
                        ),
                      ),
                      const SizedBox(height: 12),

                      InkWell(
                        onTap: () => _showLotStockPage(context),
                        borderRadius: BorderRadius.circular(8),
                        child: _buildStatCard(
                          icon: LucideIcons.package,
                          iconColor: Colors.green,
                          iconBgColor: Colors.green.withOpacity(0.1),
                          title: 'Lot Stock Ready',
                          value: '${data.totalLotReady} lot',
                          subtitle: 'Tap untuk lihat daftar lot',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Item 3: Pengiriman
                      InkWell(
                        onTap: () => _showShipmentListPage(context, ref),
                        borderRadius: BorderRadius.circular(8),
                        child: _buildStatCard(
                          icon: LucideIcons.truck,
                          iconColor: Colors.orange,
                          iconBgColor: Colors.orange.withOpacity(0.1),
                          title: 'Pengiriman',
                          value: '${data.totalLotSent} pengiriman',
                          subtitle: 'Tap untuk kelola pengiriman',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Tombol Pengiriman
            ElevatedButton.icon(
              onPressed: () => _showShipmentListPage(context, ref),
              icon: const Icon(LucideIcons.truck,
                  color: AppColors.white, size: 20),
              label: const Text('Kelola Pengiriman',
                  style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.fieldBackground),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPlaceholder,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
