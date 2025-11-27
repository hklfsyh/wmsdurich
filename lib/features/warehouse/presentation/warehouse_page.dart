import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/core/router/dialog_transitions.dart';
import 'package:wms_durich/features/warehouse/presentation/add_buah_page.dart';
import 'package:wms_durich/features/warehouse/presentation/add_lot_stock_page.dart';
import 'package:wms_durich/features/warehouse/presentation/widgets/add_pengiriman_dialog.dart';

class WarehousePage extends StatelessWidget {
  const WarehousePage({super.key});

  void _showAddBuahDialog(BuildContext context) {
    // Navigasi ke halaman Add Buah
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBuahPage()),
    );
  }

  void _showAddLotStockDialog(BuildContext context) {
    // Navigasi ke halaman Add Lot Stock
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddLotStockPage()),
    );
  }

  void _showKirimBuahDialog(BuildContext context) {
    DialogTransitions.showSlideUpDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      dialog: const AddPengirimanDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Data Dummy untuk statistik
    final int totalBuahMasukHariIni = 150; // kg
    final int lotStockReady = 5; // lot
    final int lotStockDikirim = 3; // lot

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Management'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Tombol Add Buah dan Add Lot Stock
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddBuahDialog(context),
                    icon: const Icon(LucideIcons.plus,
                        color: AppColors.white, size: 20),
                    label: const Text('Add Buah',
                        style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddLotStockDialog(context),
                    icon: const Icon(LucideIcons.package,
                        color: AppColors.black, size: 20),
                    label: const Text('Add Lot Stock',
                        style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                            color: AppColors.fieldBackground, width: 1.5),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Item 1: Total Buah Masuk Hari Ini
                    _buildStatCard(
                      icon: LucideIcons.truck,
                      iconColor: Colors.blue,
                      iconBgColor: Colors.blue.withOpacity(0.1),
                      title: 'Total Buah Masuk Hari Ini',
                      value: '$totalBuahMasukHariIni kg',
                      subtitle: 'Dari kebun ke gudang',
                    ),
                    const SizedBox(height: 12),

                    // Item 2: Lot Stock Ready
                    _buildStatCard(
                      icon: LucideIcons.package,
                      iconColor: Colors.green,
                      iconBgColor: Colors.green.withOpacity(0.1),
                      title: 'Lot Stock Ready',
                      value: '$lotStockReady lot',
                      subtitle: 'Siap untuk dikirim',
                    ),
                    const SizedBox(height: 12),

                    // Item 3: Lot Stock Dikirim
                    _buildStatCard(
                      icon: LucideIcons.send,
                      iconColor: Colors.orange,
                      iconBgColor: Colors.orange.withOpacity(0.1),
                      title: 'Lot Stock Dikirim',
                      value: '$lotStockDikirim lot',
                      subtitle: 'Dalam perjalanan ke toko',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Tombol Kirim Buah
            ElevatedButton.icon(
              onPressed: () => _showKirimBuahDialog(context),
              icon: const Icon(LucideIcons.send,
                  color: AppColors.white, size: 20),
              label: const Text('Kirim Buah',
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
