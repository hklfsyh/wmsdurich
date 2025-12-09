import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/data/models/shipment_models.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/shipment_provider.dart';

class VerifyIncomingShipmentPage extends ConsumerStatefulWidget {
  final String shipmentId;

  const VerifyIncomingShipmentPage({super.key, required this.shipmentId});

  @override
  ConsumerState<VerifyIncomingShipmentPage> createState() =>
      _VerifyIncomingShipmentPageState();
}

class _VerifyIncomingShipmentPageState
    extends ConsumerState<VerifyIncomingShipmentPage> {
  final Map<String, TextEditingController> _qtyControllers = {};
  final Map<String, TextEditingController> _beratControllers = {};
  final Map<String, String?> _qtyErrors = {};
  final Map<String, String?> _beratErrors = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (var controller in _qtyControllers.values) {
      controller.dispose();
    }
    for (var controller in _beratControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyAndFinalize(ShipmentDetailResponse detail) async {
    // Validate all inputs
    bool hasError = false;
    setState(() {
      _qtyErrors.clear();
      _beratErrors.clear();
    });

    for (var item in detail.items) {
      final qtyText = _qtyControllers[item.lotId]?.text.trim() ?? '';
      final beratText = _beratControllers[item.lotId]?.text.trim() ?? '';

      if (qtyText.isEmpty) {
        setState(() {
          _qtyErrors[item.lotId] = 'Masukkan qty';
        });
        hasError = true;
      } else {
        final qty = int.tryParse(qtyText);
        if (qty == null || qty <= 0) {
          setState(() {
            _qtyErrors[item.lotId] = 'Qty harus > 0';
          });
          hasError = true;
        }
      }

      if (beratText.isEmpty) {
        setState(() {
          _beratErrors[item.lotId] = 'Masukkan berat';
        });
        hasError = true;
      } else {
        final berat = double.tryParse(beratText);
        if (berat == null || berat <= 0) {
          setState(() {
            _beratErrors[item.lotId] = 'Berat harus > 0';
          });
          hasError = true;
        }
      }
    }

    if (hasError) return;

    // Confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalisasi Verifikasi?'),
        content: Text(
          'Pengiriman ${detail.header.kode} akan diverifikasi.\n\n'
          'Semua lot akan diubah statusnya menjadi READY\n'
          'dan tersimpan di gudang cabang Anda.\n\n'
          'Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusSuccessDark,
            ),
            child: const Text('Ya, Finalisasi'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);

    try {
      // Simulate API call to verify and finalize
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock: Update lot status to READY and update current_location
      // In real implementation, this would call:
      // - PUT /v1/shipments/{id}/verify
      // - Body: { lots: [{ lot_id, qty_verified, berat_verified }] }
      // Backend will:
      // 1. Update shipment status to COMPLETED
      // 2. Update each lot status to READY
      // 3. Update each lot current_location_id to admin's location

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Verifikasi berhasil! Lot sekarang READY di gudang Anda'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back and refresh
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipmentDetailAsync =
        ref.watch(verifyShipmentDetailProvider(widget.shipmentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Pengiriman Masuk'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: shipmentDetailAsync.when(
        data: (detail) => _buildContent(detail),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildContent(ShipmentDetailResponse detail) {
    final header = detail.header;
    final items = detail.items;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCard(header),
                const SizedBox(height: 16),
                _buildItemsSection(items),
              ],
            ),
          ),
        ),
        _buildBottomButton(detail),
      ],
    );
  }

  Widget _buildInfoCard(ShipmentModel header) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.orangeDark.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orangeDark.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.truck, color: AppColors.orangeDark, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      header.kode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.orangeDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dari: ${header.tujuan}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Tanggal Kirim: ${dateFormat.format(header.tglKirim)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(List<ShipmentItemModel> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Lot untuk Diverifikasi',
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
                    '${items.length} lot',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildItemTile(ShipmentItemModel item, int index) {
    // Initialize controllers if not exists
    if (!_qtyControllers.containsKey(item.lotId)) {
      _qtyControllers[item.lotId] =
          TextEditingController(text: item.qtyAmbil.toString());
    }
    if (!_beratControllers.containsKey(item.lotId)) {
      _beratControllers[item.lotId] =
          TextEditingController(text: item.beratAmbil.toStringAsFixed(1));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lot Header
          Row(
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
                      item.lotKode,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
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
            ],
          ),
          const SizedBox(height: 12),

          // Original Values
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Pengiriman (Referensi)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(LucideIcons.hash,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Qty: ${item.qtyAmbil} buah',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(LucideIcons.scale,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Berat: ${item.beratAmbil.toStringAsFixed(1)} kg',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Verification Inputs
          const Text(
            'Hasil Verifikasi Fisik',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyControllers[item.lotId],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Qty (buah)',
                    labelStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(LucideIcons.hash, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    errorText: _qtyErrors[item.lotId],
                  ),
                  onChanged: (value) {
                    if (_qtyErrors.containsKey(item.lotId)) {
                      setState(() {
                        _qtyErrors.remove(item.lotId);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _beratControllers[item.lotId],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Berat (kg)',
                    labelStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(LucideIcons.scale, size: 18),
                    suffixText: 'kg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    errorText: _beratErrors[item.lotId],
                  ),
                  onChanged: (value) {
                    if (_beratErrors.containsKey(item.lotId)) {
                      setState(() {
                        _beratErrors.remove(item.lotId);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(ShipmentDetailResponse detail) {
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
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : () => _verifyAndFinalize(detail),
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.checkCircle2,
                        size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Finalisasi Verifikasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
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
            'Gagal memuat detail pengiriman',
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
            onPressed: () =>
                ref.invalidate(verifyShipmentDetailProvider(widget.shipmentId)),
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
