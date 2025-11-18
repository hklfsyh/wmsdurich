import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wms_durich/core/constants/asset_paths.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/shared/models/dashboard_model.dart';

class SalesSummaryCard extends StatelessWidget {
  final DashboardModel model;
  const SalesSummaryCard({super.key, required this.model});

  String _formatRupiah(double amountJt) {
    final formatter =
        NumberFormat.compactSimpleCurrency(locale: 'id', name: 'Rp');
    return formatter.format(amountJt * 1000000);
  }

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
                    color: AppColors.statusSuccessLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    AssetPaths.salesGreen,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Penjualan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.statusSuccessLight,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Terjual',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.statusSuccessDark,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${model.terjualKg.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.statusSuccessDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Total Pendapatan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(
                        _formatRupiah(model.totalPendapatanJuta),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusSuccessDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    title: 'Pulping',
                    value: '${model.pulpingKg.toStringAsFixed(1)} kg',
                    bgColor: AppColors.orangeLight,
                    valueColor: AppColors.orangeDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    title: 'Hilang',
                    value: '${model.hilangPcs} pcs',
                    bgColor: AppColors.statusDangerLight,
                    valueColor: AppColors.statusDangerDark,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context,
      {required String title,
      required String value,
      required Color bgColor,
      required Color valueColor}) {
    final titleStyle = TextStyle(
      fontSize: 12,
      color: valueColor,
      fontWeight: FontWeight.bold,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
