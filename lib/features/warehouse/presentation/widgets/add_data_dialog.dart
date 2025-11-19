// lib/features/warehouse/presentation/widgets/add_data_dialog.dart
import 'package:flutter/material.dart';
import 'package:wms_durich/core/constants/asset_paths.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/presentation/widgets/add_durian_tab.dart'; // Import tab
import 'package:wms_durich/features/warehouse/presentation/widgets/add_warehouse_tab.dart'; // Import tab

class AddDataDialog extends StatelessWidget {
  const AddDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Jumlah tab
    const int tabCount = 2;

    return DefaultTabController(
      length: tabCount,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        alignment: Alignment.bottomCenter, // Menempel ke bawah
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header dan Tab Bar (di luar SingleChildScrollView)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tombol Close dan Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tambah Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Image.asset(AssetPaths.closeGray, height: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Deskripsi
                    const Text(
                      'Pilih tab untuk menambahkan data warehouse, atau data durian',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),

                    // Tab Bar (Warehouse / Durian)
                    Container(
                      height: 48, // Tinggi Tab Bar
                      decoration: BoxDecoration(
                        color: AppColors.fieldBackground,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: AppColors.white, // Indicator berwarna putih
                          boxShadow: [
                            // Shadow pada tab aktif
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: AppColors.textPrimary, // Warna teks aktif
                        unselectedLabelColor:
                            AppColors.textPlaceholder, // Warna teks tidak aktif
                        tabs: const [
                          Tab(text: 'Warehouse'),
                          Tab(text: 'Durian'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab View Content
              Flexible(
                child: TabBarView(
                  children: [
                    // Tab 1: Tambah Warehouse
                    const AddWarehouseTab(),

                    // Tab 2: Tambah Durian
                    const AddDurianTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
