import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/data/models/shipment_models.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/shipment_provider.dart';
import 'package:wms_durich/features/warehouse/presentation/shipment_detail_page.dart';
import 'package:wms_durich/features/warehouse/presentation/widgets/create_shipment_dialog.dart';

class ShipmentListPage extends ConsumerStatefulWidget {
  const ShipmentListPage({super.key});

  @override
  ConsumerState<ShipmentListPage> createState() => _ShipmentListPageState();
}

class _ShipmentListPageState extends ConsumerState<ShipmentListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateShipmentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateShipmentDialog(),
    ).then((result) {
      if (result != null && result is ShipmentModel) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShipmentDetailPage(shipmentId: result.id),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shipmentState = ref.watch(shipmentProvider);
    final draftShipments = shipmentState.draftShipments;
    final historyShipments = shipmentState.historyShipments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengiriman'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.fileEdit, size: 18),
                  const SizedBox(width: 8),
                  Text('Draft (${draftShipments.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.history, size: 18),
                  const SizedBox(width: 8),
                  Text('Riwayat (${historyShipments.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShipmentList(draftShipments, isDraft: true),
          _buildShipmentList(historyShipments, isDraft: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateShipmentDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('Buat Pengiriman',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildShipmentList(List<ShipmentModel> shipments,
      {required bool isDraft}) {
    if (shipments.isEmpty) {
      return _buildEmptyState(isDraft);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: shipments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final shipment = shipments[index];
        return _buildShipmentCard(shipment);
      },
    );
  }

  Widget _buildEmptyState(bool isDraft) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDraft ? LucideIcons.fileEdit : LucideIcons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            isDraft ? 'Tidak ada Draft Pengiriman' : 'Tidak ada Riwayat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isDraft
                ? 'Tap tombol "Buat Pengiriman" untuk membuat draft baru'
                : 'Pengiriman yang sudah dikirim akan tampil di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentCard(ShipmentModel shipment) {
    final statusColor = _getStatusColor(shipment.status);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShipmentDetailPage(shipmentId: shipment.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(shipment.status),
                    color: statusColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipment.tujuan,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${shipment.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      shipment.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: LucideIcons.calendar,
                      label: 'Tanggal Kirim',
                      value: dateFormat.format(shipment.tglKirim),
                      color: AppColors.blueDark,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: LucideIcons.package,
                      label: 'Total Lot',
                      value: '${shipment.totalItems}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      icon: LucideIcons.scale,
                      label: 'Total Berat',
                      value: '${shipment.totalBerat.toStringAsFixed(1)} kg',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.05),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.eye, size: 16, color: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    shipment.status == 'DRAFT' ? 'Kelola Muatan' : 'Lihat Detail',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(LucideIcons.chevronRight, size: 16, color: statusColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DRAFT':
        return Colors.grey;
      case 'SENDING':
        return AppColors.orangeDark;
      case 'COMPLETED':
        return AppColors.statusSuccessDark;
      case 'CANCELLED':
        return AppColors.statusDangerDark;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'DRAFT':
        return LucideIcons.fileEdit;
      case 'SENDING':
        return LucideIcons.truck;
      case 'COMPLETED':
        return LucideIcons.checkCircle;
      case 'CANCELLED':
        return LucideIcons.xCircle;
      default:
        return LucideIcons.circle;
    }
  }
}
