// lib/features/warehouse/presentation/widgets/warehouse_item_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wms_durich/core/constants/asset_paths.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/shared/models/warehouse_model.dart';

class WarehouseItemCard extends StatelessWidget {
  final WarehouseModel model;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WarehouseItemCard({
    super.key,
    required this.model,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final conditionData = DurianConditionData.fromCondition(model.condition);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.fieldBackground),
      ),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row ID & Status & Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // WH ID dan Status
                Row(
                  children: [
                    // WH ID Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        model.warehouseId,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Condition Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: conditionData.bgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        conditionData.label,
                        style: TextStyle(
                          color: conditionData.textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Action Buttons
                Row(
                  children: [
                    // Edit Button
                    GestureDetector(
                      onTap: onEdit,
                      child: Image.asset(AssetPaths.editBlue, height: 20),
                    ),
                    const SizedBox(width: 12),

                    // Delete Button
                    GestureDetector(
                      onTap: onDelete,
                      child: Image.asset(AssetPaths.deleteRed, height: 20),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Detail Buah
            Text(
              model.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Berat: ${model.weightKg.toStringAsFixed(1)} kg',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('d MMMM yyyy').format(model.entryDate),
              style: const TextStyle(
                fontSize: 12, // Tetap 12
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
