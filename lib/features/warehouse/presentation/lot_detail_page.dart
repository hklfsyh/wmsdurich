import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/data/models/lot_models.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/lot_provider.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/master_data_provider.dart';

class LotDetailPage extends ConsumerStatefulWidget {
  final String lotId;

  const LotDetailPage({super.key, required this.lotId});

  @override
  ConsumerState<LotDetailPage> createState() => _LotDetailPageState();
}

class _LotDetailPageState extends ConsumerState<LotDetailPage> {
  final TextEditingController _beratController = TextEditingController();
  String? _beratError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _beratController.dispose();
    super.dispose();
  }

  Future<void> _finalizeLot(LotModel header) async {
    setState(() {
      _beratError = null;
    });

    final beratText = _beratController.text.trim();
    if (beratText.isEmpty) {
      setState(() {
        _beratError = 'Masukkan berat total';
      });
      return;
    }

    final berat = double.tryParse(beratText);
    if (berat == null || berat <= 0) {
      setState(() {
        _beratError = 'Berat harus lebih dari 0 kg';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = FinalizeLotRequest();
      final result = await ref
          .read(finalizeLotControllerProvider.notifier)
          .finalize(widget.lotId, request);

      if (result != null) {
        ref.invalidate(lotDetailProvider(widget.lotId));
        ref.invalidate(allDraftLotsProvider);
        ref.invalidate(warehouseDataProvider);

        if (mounted) {
          _showSuccessSnackbar(
            'Lot ${header.kode} berhasil dijadikan Ready dengan berat $berat kg',
          );
        }
      } else {
        if (mounted) {
          _showErrorSnackbar('Gagal memfinalisasi lot');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Terjadi kesalahan: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.checkCircle2,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.statusSuccessDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.xCircle,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.statusDangerDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lotDetailAsync = ref.watch(lotDetailProvider(widget.lotId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lot'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(lotDetailProvider(widget.lotId)),
            icon: const Icon(LucideIcons.refreshCw),
          ),
        ],
      ),
      body: lotDetailAsync.when(
        data: (detail) => _buildContent(detail),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildContent(LotDetailResponse detail) {
    final header = detail.header;
    final items = detail.items;
    final isReady = header.status == 'READY';

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(lotDetailProvider(widget.lotId));
        // Wait for the provider to refresh
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(header),
                  const SizedBox(height: 16),
                  _buildInfoSection(header),
                  const SizedBox(height: 16),
                  _buildItemsSection(items),
                  if (!isReady) ...[
                    const SizedBox(height: 16),
                    _buildFinalizeSection(header),
                  ],
                ],
              ),
            ),
          ),
          if (!isReady) _buildBottomButton(header),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(LotModel header) {
    final isReady = header.status == 'READY';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isReady ? AppColors.statusSuccessLight : AppColors.orangeLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReady
              ? AppColors.statusSuccessDark.withOpacity(0.3)
              : AppColors.orangeDark.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.package,
            color: isReady ? AppColors.statusSuccessDark : AppColors.orangeDark,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  header.kode,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isReady
                        ? AppColors.statusSuccessDark
                        : AppColors.orangeDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${header.status == 'DRAFT' ? header.currentQty : header.qtyAwal} Buah',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isReady ? AppColors.statusSuccessDark : AppColors.orangeDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              header.status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(LotModel header) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Lot',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: LucideIcons.tag,
                  label: 'Jenis Durian',
                  value: header.jenisDurianNama,
                  color: AppColors.blueDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  icon: LucideIcons.star,
                  label: 'Kondisi',
                  value: header.kondisiBuah,
                  color: AppColors.orangeDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: LucideIcons.scale,
                  label: 'Berat Awal',
                  value: '${header.beratAwal} kg',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  icon: LucideIcons.hash,
                  label: header.status == 'DRAFT' ? 'Qty Saat Ini' : 'Qty Awal',
                  value:
                      '${header.status == 'DRAFT' ? header.currentQty : header.qtyAwal} buah',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(List<LotDetailItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Buah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} item',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(LucideIcons.packageX,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada buah dalam lot ini',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildItemTile(item, index + 1);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildItemTile(LotDetailItem item, int index) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.blueDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.kodeBuah,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.mapPin,
                        size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      item.asalBlok,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(LucideIcons.calendar,
                        size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(item.tglPanen),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.scale,
                        size: 12, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${item.berat.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalizeSection(LotModel header) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Finalisasi Lot',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan berat total untuk mengubah status lot menjadi READY',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Berat Total (kg)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _beratController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              hintText: 'Masukkan berat total dalam kg',
              hintStyle: const TextStyle(fontSize: 14),
              suffixText: 'kg',
              suffixStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              prefixIcon: const Icon(LucideIcons.scale, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              errorText: _beratError,
            ),
            onChanged: (value) {
              if (_beratError != null) {
                setState(() {
                  _beratError = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(LotModel header) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : () => _finalizeLot(header),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.statusSuccessDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.checkCircle2, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Selesai / Jadikan Siap (Ready)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 64,
            color: AppColors.statusDangerDark,
          ),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat detail lot',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$error',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(lotDetailProvider(widget.lotId)),
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
