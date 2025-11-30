import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/data/models/shipment_models.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/shipment_provider.dart';
import 'package:wms_durich/features/warehouse/presentation/widgets/add_item_to_shipment_dialog.dart';

class ShipmentDetailPage extends ConsumerStatefulWidget {
  final String shipmentId;

  const ShipmentDetailPage({super.key, required this.shipmentId});

  @override
  ConsumerState<ShipmentDetailPage> createState() => _ShipmentDetailPageState();
}

class _ShipmentDetailPageState extends ConsumerState<ShipmentDetailPage> {
  bool _isFinalizingLoading = false;

  void _showAddItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemToShipmentDialog(shipmentId: widget.shipmentId),
    );
  }

  Future<void> _removeItem(ShipmentItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.statusDangerLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.trash2, color: AppColors.statusDangerDark, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Hapus Item', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus item ini dari muatan?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.fieldBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.package, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${item.lotKode} - ${item.jenisDurian}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDangerDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(shipmentProvider.notifier).removeItemFromShipment(
            shipmentId: widget.shipmentId,
            itemId: item.id,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Item ${item.lotKode} berhasil dihapus'),
              ],
            ),
            backgroundColor: AppColors.statusSuccessDark,
          ),
        );
      }
    }
  }

  Future<void> _finalizeShipment() async {
    final shipment = ref.read(shipmentDetailProvider(widget.shipmentId));
    final items = ref.read(shipmentItemsProvider(widget.shipmentId));

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(LucideIcons.alertCircle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Tidak ada item dalam muatan'),
            ],
          ),
          backgroundColor: AppColors.statusWarningDark,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.statusSuccessLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.truck, color: AppColors.statusSuccessDark, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Kirim Sekarang?', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Setelah dikirim, stok akan dipotong dan pengiriman tidak dapat diubah lagi.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blueLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 16, color: AppColors.blueDark),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          shipment?.tujuan ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(LucideIcons.package, size: 16, color: AppColors.blueDark),
                      const SizedBox(width: 8),
                      Text(
                        '${items.length} Lot',
                        style: const TextStyle(color: AppColors.blueDark),
                      ),
                      const SizedBox(width: 16),
                      const Icon(LucideIcons.scale, size: 16, color: AppColors.blueDark),
                      const SizedBox(width: 8),
                      Text(
                        '${shipment?.totalBerat.toStringAsFixed(1)} kg',
                        style: const TextStyle(color: AppColors.blueDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusSuccessDark,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(LucideIcons.truck, size: 18),
            label: const Text('Kirim'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isFinalizingLoading = true);

      try {
        await ref.read(shipmentProvider.notifier).finalizeShipment(widget.shipmentId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Pengiriman berhasil diproses!'),
                ],
              ),
              backgroundColor: AppColors.statusSuccessDark,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memproses pengiriman: $e'),
              backgroundColor: AppColors.statusDangerDark,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isFinalizingLoading = false);
        }
      }
    }
  }

  Future<void> _cancelShipment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.statusDangerLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.xCircle, color: AppColors.statusDangerDark, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Batalkan Pengiriman?', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan draft pengiriman ini? Semua item muatan akan dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDangerDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(shipmentProvider.notifier).cancelShipment(widget.shipmentId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Pengiriman berhasil dibatalkan'),
              ],
            ),
            backgroundColor: AppColors.statusDangerDark,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipment = ref.watch(shipmentDetailProvider(widget.shipmentId));
    final items = ref.watch(shipmentItemsProvider(widget.shipmentId));
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    if (shipment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pengiriman')),
        body: const Center(child: Text('Pengiriman tidak ditemukan')),
      );
    }

    final isDraft = shipment.status == 'DRAFT';
    final statusColor = _getStatusColor(shipment.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pengiriman'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isDraft)
            PopupMenuButton<String>(
              icon: const Icon(LucideIcons.moreVertical),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'cancel') {
                  _cancelShipment();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(LucideIcons.xCircle, size: 18, color: AppColors.statusDangerDark),
                      SizedBox(width: 12),
                      Text('Batalkan Draft', style: TextStyle(color: AppColors.statusDangerDark)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderCard(shipment, statusColor, dateFormat),
          const SizedBox(height: 8),
          _buildSummaryRow(shipment, items),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? _buildEmptyItemsState(isDraft)
                : _buildItemsList(items, isDraft),
          ),
        ],
      ),
      bottomNavigationBar: isDraft ? _buildBottomBar(items) : null,
    );
  }

  Widget _buildHeaderCard(ShipmentModel shipment, Color statusColor, DateFormat dateFormat) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStatusIcon(shipment.status),
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shipment.id,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusLabel(shipment.status),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: LucideIcons.mapPin,
                  label: 'Tujuan',
                  value: shipment.tujuan,
                  color: AppColors.blueDark,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: LucideIcons.calendar,
                  label: 'Tanggal Kirim',
                  value: dateFormat.format(shipment.tglKirim),
                  color: AppColors.orangeDark,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: LucideIcons.user,
                  label: 'Dibuat Oleh',
                  value: shipment.createdBy ?? '-',
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(ShipmentModel shipment, List<ShipmentItemModel> items) {
    final totalQty = items.fold<int>(0, (sum, item) => sum + item.qtyAmbil);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: LucideIcons.layers,
              label: 'Total Lot',
              value: '${items.length}',
              color: AppColors.blueDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildStatItem(
              icon: LucideIcons.package,
              label: 'Total Qty',
              value: '$totalQty buah',
              color: AppColors.statusSuccessDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildStatItem(
              icon: LucideIcons.scale,
              label: 'Total Berat',
              value: '${shipment.totalBerat.toStringAsFixed(1)} kg',
              color: AppColors.orangeDark,
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
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
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
        ),
      ],
    );
  }

  Widget _buildEmptyItemsState(bool isDraft) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.fieldBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.packageOpen,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada item muatan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isDraft
                ? 'Tap tombol "Tambah Item" untuk memuat Lot'
                : 'Pengiriman ini tidak memiliki item',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          if (isDraft) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddItemDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Tambah Item'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsList(List<ShipmentItemModel> items, bool isDraft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Muatan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              if (isDraft)
                TextButton.icon(
                  onPressed: _showAddItemDialog,
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Tambah'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemCard(item, isDraft, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(ShipmentItemModel item, bool isDraft, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.blueLight.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blueDark,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.lotKode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        item.jenisDurian,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDraft)
                  IconButton(
                    onPressed: () => _removeItem(item),
                    icon: const Icon(LucideIcons.trash2, size: 18),
                    color: AppColors.statusDangerDark,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _buildItemStat(
                    icon: LucideIcons.leaf,
                    label: 'Kondisi',
                    value: item.kondisiBuah,
                  ),
                ),
                Expanded(
                  child: _buildItemStat(
                    icon: LucideIcons.package,
                    label: 'Qty',
                    value: '${item.qtyAmbil} buah',
                  ),
                ),
                Expanded(
                  child: _buildItemStat(
                    icon: LucideIcons.scale,
                    label: 'Berat',
                    value: '${item.beratAmbil.toStringAsFixed(1)} kg',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(List<ShipmentItemModel> items) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showAddItemDialog,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Tambah Item'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: items.isEmpty || _isFinalizingLoading ? null : _finalizeShipment,
              icon: _isFinalizingLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(LucideIcons.truck, size: 18),
              label: Text(_isFinalizingLoading ? 'Memproses...' : 'Kirim Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusSuccessDark,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
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

  String _getStatusLabel(String status) {
    switch (status) {
      case 'DRAFT':
        return 'Draft';
      case 'SENDING':
        return 'Dalam Pengiriman';
      case 'COMPLETED':
        return 'Selesai';
      case 'CANCELLED':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
