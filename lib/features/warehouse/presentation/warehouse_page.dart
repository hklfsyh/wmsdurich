import 'package:flutter/material.dart';
import 'package:wms_durich/core/constants/asset_paths.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/core/router/dialog_transitions.dart';
import 'package:wms_durich/shared/widgets/app_notification.dart';
import 'package:wms_durich/features/warehouse/presentation/widgets/warehouse_item_card.dart';
import 'package:wms_durich/features/warehouse/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:wms_durich/features/warehouse/presentation/widgets/edit_data_dialog.dart';
import 'package:wms_durich/features/warehouse/presentation/widgets/add_data_dialog.dart';
import 'package:wms_durich/features/warehouse/presentation/widgets/add_pengiriman_dialog.dart';
import 'package:wms_durich/shared/models/warehouse_model.dart';

class WarehousePage extends StatelessWidget {
  const WarehousePage({super.key});

  void _showDeleteDialog(BuildContext context, WarehouseModel item) {
    DialogTransitions.showAnimatedDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      dialog: DeleteConfirmationDialog(
        item: item,
        onConfirm: () {
          AppNotification.show(
            context,
            message: 'Data ${item.warehouseId} berhasil dihapus',
            type: NotificationType.success,
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, WarehouseModel item) {
    DialogTransitions.showSlideUpDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      dialog: EditDataDialog(
        item: item,
        onSave: (newCondition, newWeight) {
          AppNotification.show(
            context,
            message: 'Data ${item.warehouseId} berhasil diperbarui',
            type: NotificationType.success,
          );
        },
      ),
    );
  }

  void _showAddDataDialog(BuildContext context) {
    DialogTransitions.showSlideUpDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      dialog: const AddDataDialog(),
    );
  }

  void _showAddPengirimanDialog(BuildContext context) {
    DialogTransitions.showSlideUpDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      dialog: const AddPengirimanDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Data Dummy
    final data = WarehouseModel.dummyData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Management'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // 1. Search Bar dan Refresh Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari ID atau nama buah...',
                      hintStyle:
                          const TextStyle(color: AppColors.textPlaceholder),
                      prefixIcon:
                          Image.asset(AssetPaths.searchGray, height: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.fieldBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.fieldBackground),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Image.asset(AssetPaths.refreshBlack, height: 20),
                    onPressed: () {
                      AppNotification.show(
                        context,
                        message: 'Data berhasil direfresh',
                        type: NotificationType.success,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Add Data Button dan Add Pengiriman Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showAddDataDialog(context);
                    },
                    icon: const Icon(Icons.add, color: AppColors.white),
                    label: const Text('Add Data',
                        style: TextStyle(color: AppColors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showAddPengirimanDialog(context);
                    },
                    icon: Image.asset(AssetPaths.truckBlack,
                        height: 20), // Ikon Add Pengiriman
                    label: const Text('Add Pengiriman',
                        style: TextStyle(color: AppColors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side:
                            const BorderSide(color: AppColors.fieldBackground),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Status Display
            const Text(
              'Menampilkan 4 data terbaru',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 8),

            // 4. List Data Warehouse
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 1.0),
                    child: WarehouseItemCard(
                      model: item,
                      onEdit: () {
                        _showEditDialog(context, item);
                      },
                      onDelete: () {
                        _showDeleteDialog(context, item);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
