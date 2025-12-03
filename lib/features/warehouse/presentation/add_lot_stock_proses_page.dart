import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/data/models/lot_models.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/lot_provider.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/master_data_provider.dart';

/// Lotting Terminal - New Flow Implementation
///
/// Stage 1: Create Lot DRAFT (pilih jenis & kondisi)
/// Stage 2: Serial Input (ID Buah + Berat, auto-submit on Enter)
/// - Live summary: total items & total berat
/// - Tombol "Done" → finalisasi Lot (DRAFT → READY TO SEND)
class AddLotStockProsesPage extends ConsumerStatefulWidget {
  const AddLotStockProsesPage({super.key});

  @override
  ConsumerState<AddLotStockProsesPage> createState() =>
      _AddLotStockProsesPageState();
}

class _AddLotStockProsesPageState extends ConsumerState<AddLotStockProsesPage> {
  // Stage Management
  int _currentStage = 1; // 1 = Create Lot DRAFT, 2 = Serial Input

  // Stage 1: Lot Creation
  String? _selectedJenisId;
  String? _selectedKondisi;
  String? _jenisError;
  String? _kondisiError;
  bool _isCreatingLot = false;

  // Stage 2: Lot Data
  String? _lotId; // Used for real API calls
  String? _lotKode;
  String? _lotJenisNama;

  // Stage 2: Serial Input
  final TextEditingController _idBuahController = TextEditingController();
  final TextEditingController _beratController = TextEditingController();
  final FocusNode _idBuahFocus = FocusNode();
  final FocusNode _beratFocus = FocusNode();

  // Stage 2: Live Summary
  int _totalItems = 0;
  double _totalBerat = 0.0;
  final List<Map<String, dynamic>> _addedItems = [];
  bool _isAddingItem = false;

  // Stage 2: Finalization
  bool _isFinalizing = false;

  final List<Map<String, String>> _kondisiOptions = [
    {'value': 'A', 'label': 'A - Bagus'},
    {'value': 'B', 'label': 'B - Rusak Sebagian / Bakal Pulping'},
    {'value': 'M', 'label': 'M - Belum Masak'},
    {'value': 'R', 'label': 'R - Reject / Rusak / Busuk'},
  ];

  @override
  void dispose() {
    _idBuahController.dispose();
    _beratController.dispose();
    _idBuahFocus.dispose();
    _beratFocus.dispose();
    super.dispose();
  }

  // ==================== STAGE 1: CREATE LOT DRAFT ====================

  Future<void> _createLotDraft() async {
    setState(() {
      _jenisError = null;
      _kondisiError = null;
    });

    if (_selectedJenisId == null) {
      setState(() {
        _jenisError = 'Pilih jenis durian';
      });
      return;
    }

    if (_selectedKondisi == null) {
      setState(() {
        _kondisiError = 'Pilih kondisi buah';
      });
      return;
    }

    setState(() {
      _isCreatingLot = true;
    });

    try {
      final controller = ref.read(createLotControllerProvider.notifier);
      final request = CreateLotRequest(
        jenisDurianId: _selectedJenisId!,
        kondisiBuah: _selectedKondisi!,
      );

      final response = await controller.createLot(request);

      if (response == null) {
        throw Exception('Failed to create lot');
      }

      setState(() {
        _lotId = response.id;
        _lotKode = response.kode;
        _lotJenisNama = response.jenisDurianNama;
        _currentStage = 2;
        _isCreatingLot = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Lot DRAFT berhasil dibuat: ${response.kode}'),
            backgroundColor: Colors.green,
          ),
        );

        // Auto-focus ke input ID Buah
        Future.delayed(const Duration(milliseconds: 300), () {
          _idBuahFocus.requestFocus();
        });
      }
    } catch (e) {
      setState(() {
        _isCreatingLot = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Gagal membuat lot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==================== STAGE 2: SERIAL INPUT ====================

  Future<void> _submitItem() async {
    final idBuah = _idBuahController.text.trim();
    final beratText = _beratController.text.trim();

    if (idBuah.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✗ ID Buah tidak boleh kosong'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    if (beratText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✗ Berat tidak boleh kosong'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final berat = double.tryParse(beratText);
    if (berat == null || berat <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✗ Berat harus berupa angka positif'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _isAddingItem = true;
    });

    try {
      // Simulate API call to add item to lot (MOCK)
      // Real: await lotRepository.addItemToLot(lotId, idBuah, berat)
      await Future.delayed(const Duration(milliseconds: 500));

      // Update local state
      setState(() {
        _totalItems++;
        _totalBerat += berat;
        _addedItems.insert(0, {
          'idBuah': idBuah,
          'berat': berat,
          'timestamp': DateTime.now(),
        });

        _idBuahController.clear();
        _beratController.clear();
        _isAddingItem = false;
      });

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Item ditambahkan: $idBuah ($berat kg)'),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 800),
          ),
        );

        // Auto-focus back to ID Buah input
        _idBuahFocus.requestFocus();
      }
    } catch (e) {
      setState(() {
        _isAddingItem = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Gagal menambahkan item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==================== STAGE 2: FINALIZATION ====================

  Future<void> _finalizeLot() async {
    if (_totalItems == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✗ Tidak ada item yang ditambahkan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Confirm before finalizing
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.checkCircle, color: AppColors.primary, size: 24),
            SizedBox(width: 12),
            Text('Finalisasi Lot?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menyelesaikan lot ini?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Kode Lot', _lotKode ?? '-'),
                  const Divider(),
                  _buildSummaryRow('Total Item', '$_totalItems buah'),
                  const Divider(),
                  _buildSummaryRow(
                      'Total Berat', '${_totalBerat.toStringAsFixed(2)} kg'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Status akan berubah menjadi READY TO SEND',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Finalisasi'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isFinalizing = true;
    });

    try {
      // Simulate API call to finalize lot (MOCK)
      // Real: await lotRepository.finalizeLot(lotId, totalBerat)
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Lot $_lotKode berhasil difinalisasi!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isFinalizing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Gagal finalisasi lot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==================== UI BUILDERS ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentStage == 1 ? 'Buat Lot Baru' : 'Lotting Terminal'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // DEMO Badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'DEMO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: _currentStage == 1
          ? _buildStage1CreateLot()
          : _buildStage2SerialInput(),
    );
  }

  Widget _buildStage1CreateLot() {
    final jenisDurianAsync = ref.watch(jenisDurianProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.info, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Buat Lot DRAFT untuk memulai input serial',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Jenis Durian
          const Text(
            'Jenis Durian',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          jenisDurianAsync.when(
            data: (jenisList) => DropdownButtonFormField<String>(
              value: _selectedJenisId,
              decoration: InputDecoration(
                hintText: 'Pilih jenis durian',
                errorText: _jenisError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: jenisList
                  .map((jenis) => DropdownMenuItem<String>(
                        value: jenis.id,
                        child: Text(jenis.displayName),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedJenisId = value;
                  _jenisError = null;
                });
              },
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 24),

          // Kondisi Buah
          const Text(
            'Kondisi Buah',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedKondisi,
            decoration: InputDecoration(
              hintText: 'Pilih kondisi',
              errorText: _kondisiError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: _kondisiOptions
                .map((kondisi) => DropdownMenuItem<String>(
                      value: kondisi['value'],
                      child: Text(kondisi['label']!),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedKondisi = value;
                _kondisiError = null;
              });
            },
          ),
          const SizedBox(height: 40),

          // Create Button
          ElevatedButton(
            onPressed: _isCreatingLot ? null : _createLotDraft,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isCreatingLot
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
                      Icon(LucideIcons.plus),
                      SizedBox(width: 12),
                      Text(
                        'Buat Lot DRAFT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage2SerialInput() {
    return Column(
      children: [
        // Lot Header - TETAP di luar SingleChildScrollView
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.package,
                      color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lotKode ?? '-',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          _lotJenisNama ?? '-',
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
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'DRAFT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Konten Utama (Form Input + Summary + List) - DIBUNGKUS S.C.V
        Expanded(
          child: SingleChildScrollView(
            // Padding harus ada di dalam S.C.V
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                // Input Form (Input ID Buah & Berat)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ID Buah Input
                      TextField(
                        controller: _idBuahController,
                        focusNode: _idBuahFocus,
                        decoration: InputDecoration(
                          labelText: 'ID Buah',
                          hintText: 'Scan atau ketik ID buah',
                          prefixIcon: const Icon(LucideIcons.scan),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onSubmitted: (_) {
                          _beratFocus.requestFocus();
                        },
                      ),
                      const SizedBox(height: 12),

                      // Berat Input
                      TextField(
                        controller: _beratController,
                        focusNode: _beratFocus,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Berat (kg)',
                          hintText: 'Masukkan berat',
                          prefixIcon: const Icon(LucideIcons.scale),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onSubmitted: (_) {
                          _submitItem();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Submit Button (Optional - bisa dipindah ke bottom bar jika lebih baik)
                      ElevatedButton(
                        onPressed: _isAddingItem ? null : _submitItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isAddingItem
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.plus, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tambah Item (Enter)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Live Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border(
                      bottom:
                          BorderSide(color: Colors.green.shade200, width: 2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Item',
                          '$_totalItems',
                          LucideIcons.hash,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Berat',
                          '${_totalBerat.toStringAsFixed(2)} kg',
                          LucideIcons.scale,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // Items List (Gunakan ListView.builder di sini)
                // Karena ListView.separated butuh expanded, kita akan memindahkan list ke dalam SingleChildScrollView
                if (_addedItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Item Ditambahkan (Terakhir di Atas)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ..._addedItems
                            .map((item) => _buildItemCard(item))
                            .toList(),
                      ],
                    ),
                  ),

                if (_addedItems.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Column(
                        children: [
                          Icon(LucideIcons.inbox,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada item yang ditambahkan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Finalize Button - TETAP di luar SingleChildScrollView
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
            onPressed: _totalItems > 0 && !_isFinalizing ? _finalizeLot : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isFinalizing
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
                      Icon(LucideIcons.checkCircle, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Finalisasi Lot (DRAFT → READY)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final idBuah = item['idBuah'] as String;
    final berat = item['berat'] as double;
    final timestamp = item['timestamp'] as DateTime;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.package,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  idBuah,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${berat.toStringAsFixed(2)} kg',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
