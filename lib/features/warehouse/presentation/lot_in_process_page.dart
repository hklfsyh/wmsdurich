import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';

// Model untuk Lot In-Process
class LotInProcess {
  final String id;
  final String jenis;
  final String kondisi;
  final int jumlahBuah;
  double? beratTotal; // kg
  bool isCompleted;

  LotInProcess({
    required this.id,
    required this.jenis,
    required this.kondisi,
    required this.jumlahBuah,
    this.beratTotal,
    this.isCompleted = false,
  });
}

class LotInProcessPage extends StatefulWidget {
  const LotInProcessPage({super.key});

  @override
  State<LotInProcessPage> createState() => _LotInProcessPageState();
}

class _LotInProcessPageState extends State<LotInProcessPage> {
  // Mock data lot in-process
  final List<LotInProcess> _lotsInProcess = [
    LotInProcess(
      id: 'LOT-001',
      jenis: 'MK',
      kondisi: 'A',
      jumlahBuah: 25,
    ),
    LotInProcess(
      id: 'LOT-005',
      jenis: 'BT',
      kondisi: 'B',
      jumlahBuah: 18,
    ),
    LotInProcess(
      id: 'LOT-006',
      jenis: 'F0001',
      kondisi: 'A',
      jumlahBuah: 30,
    ),
  ];

  // Controllers untuk input berat
  final Map<String, TextEditingController> _beratControllers = {};
  final Map<String, String?> _beratErrors = {};

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller untuk setiap lot
    for (var lot in _lotsInProcess) {
      _beratControllers[lot.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose semua controller
    for (var controller in _beratControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitLot(LotInProcess lot) {
    // Reset error
    setState(() {
      _beratErrors[lot.id] = null;
    });

    // Validasi berat total
    final beratText = _beratControllers[lot.id]!.text.trim();
    if (beratText.isEmpty) {
      setState(() {
        _beratErrors[lot.id] = 'Masukkan berat total';
      });
      return; // STOP - jangan lanjut ke snackbar
    }

    final berat = double.tryParse(beratText);
    if (berat == null || berat <= 0) {
      setState(() {
        _beratErrors[lot.id] = 'Berat harus lebih dari 0 kg';
      });
      return; // STOP - jangan lanjut ke snackbar
    }

    // Jika validasi berhasil, simpan berat dan tandai sebagai completed
    setState(() {
      lot.beratTotal = berat;
      lot.isCompleted = true;
    });

    // Tampilkan custom snackbar sukses (hanya jika validasi berhasil)
    _showSuccessSnackbar(
      'Lot ${lot.id} berhasil dijadikan Ready dengan berat ${lot.beratTotal} kg',
    );

    // TODO: Simpan ke database dengan status 'Ready'
    // API call atau state management untuk update status lot
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
        margin: const EdgeInsets.only(
          top: 80, // Posisi di bawah appbar (sekitar 80-100px dari atas)
          left: 16,
          right: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: '✕',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _backToWarehouse() {
    // Kembali ke halaman warehouse
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final allCompleted = _lotsInProcess.every((lot) => lot.isCompleted);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Lot Stock - Detail'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.packageOpen,
                    color: AppColors.blueDark, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lot In-Process',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_lotsInProcess.length} Lot',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blueDark,
                        ),
                      ),
                    ],
                  ),
                ),
                if (allCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.statusSuccessDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.checkCircle2,
                            size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Semua Selesai',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // List Lot In-Process
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _lotsInProcess.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final lot = _lotsInProcess[index];
                return _buildLotCard(lot);
              },
            ),
          ),

          // Bottom Button
          Container(
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
              onPressed: _backToWarehouse,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.arrowLeft, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Kembali ke Warehouse',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLotCard(LotInProcess lot) {
    final controller = _beratControllers[lot.id]!;
    final error = _beratErrors[lot.id];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: lot.isCompleted
              ? AppColors.statusSuccessDark
              : Colors.grey.shade300,
          width: lot.isCompleted ? 2 : 1,
        ),
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
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lot.isCompleted
                  ? AppColors.statusSuccessLight
                  : Colors.grey.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.package,
                  color: lot.isCompleted
                      ? AppColors.statusSuccessDark
                      : AppColors.blueDark,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lot.id,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: lot.isCompleted
                              ? AppColors.statusSuccessDark
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lot.jumlahBuah} Buah',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (lot.isCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.statusSuccessDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.check, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Ready',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Detail Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Detail Info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: LucideIcons.tag,
                        label: 'Jenis',
                        value: lot.jenis,
                        color: AppColors.blueDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        icon: LucideIcons.star,
                        label: 'Kondisi',
                        value: lot.kondisi,
                        color: AppColors.orangeDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Input Berat Total
                const Text(
                  'Berat Total (kg)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller,
                  enabled: !lot.isCompleted,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    filled: true,
                    fillColor:
                        lot.isCompleted ? Colors.grey.shade100 : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    errorText: error,
                  ),
                  onChanged: (value) {
                    if (error != null) {
                      setState(() {
                        _beratErrors[lot.id] = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Button
                if (!lot.isCompleted)
                  ElevatedButton(
                    onPressed: () => _submitLot(lot),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusSuccessDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.checkCircle2,
                            size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Selesai / Jadikan Siap (Ready)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.statusSuccessLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.statusSuccessDark.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.checkCircle2,
                            color: AppColors.statusSuccessDark, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lot berhasil dijadikan Ready',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.statusSuccessDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Berat: ${lot.beratTotal} kg',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
