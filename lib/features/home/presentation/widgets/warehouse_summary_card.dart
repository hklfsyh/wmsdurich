import 'package:flutter/material.dart';
import 'package:wms_durich/core/constants/asset_paths.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/shared/models/dashboard_model.dart';

class WarehouseSummaryCard extends StatelessWidget {
  final DashboardModel model;
  const WarehouseSummaryCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    AssetPaths.boxBlue,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Warehouse',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    )),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.0,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildStatusItem(
                  context,
                  title: 'Total Durian',
                  value: model.totalDurian.toString(),
                  bgColor: AppColors.white,
                  valueColor: AppColors.textPrimary,
                  isStatusTitle: true,
                ),
                _buildStatusItem(
                  context,
                  title: 'Bagus',
                  value: model.bagus.toString(),
                  bgColor: AppColors.statusSuccessLight,
                  valueColor: AppColors.statusSuccessDark,
                  isStatusTitle: true,
                ),
                _buildStatusItem(
                  context,
                  title: 'Busuk',
                  value: model.busuk.toString(),
                  bgColor: AppColors.statusWarningLight,
                  valueColor: AppColors.statusWarningDark,
                  isStatusTitle: true,
                ),
                _buildStatusItem(
                  context,
                  title: 'Hilang',
                  value: model.hilang.toString(),
                  bgColor: AppColors.statusDangerLight,
                  valueColor: AppColors.statusDangerDark,
                  isStatusTitle: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required String title,
    required String value,
    required Color bgColor,
    required Color valueColor,
    bool isBoldValue = false,
    bool isStatusTitle = false,
  }) {
    final titleStyle = TextStyle(
      fontSize: 12,
      color: isStatusTitle ? valueColor : AppColors.textSecondary,
      fontWeight: isStatusTitle ? FontWeight.bold : FontWeight.w400,
    );

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              title,
              style: titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isBoldValue ? FontWeight.w900 : FontWeight.bold,
                color: valueColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
