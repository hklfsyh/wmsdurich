import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/data/models/lot_models.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/lot_provider.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/master_data_provider.dart';

class AddLotStockProsesPage extends ConsumerStatefulWidget {
  const AddLotStockProsesPage({super.key});

  @override
  ConsumerState<AddLotStockProsesPage> createState() =>
      _AddLotStockProsesPageState();
}

class _AddLotStockProsesPageState extends ConsumerState<AddLotStockProsesPage> {
  // Stage: 'create' or 'scanning'
  String _stage = 'create';

  // Create Lot Stage
  String? _selectedJenisDurianId;
  String? _selectedKondisi;
  final _kondisiOptions = [
    {'value': 'Premium', 'label': 'Premium - Kualitas Terbaik'},
    {'value': 'Standard', 'label': 'Standard - Kualitas Baik'},
    {'value': 'Grade B', 'label': 'Grade B - Ada Cacat Kecil'},
    {'value': 'Reject', 'label': 'Reject - Rusak/Busuk'},
  ];

  // Created Lot Info
  String? _createdLotId;
  String? _createdLotKode;

  // Scanning Stage
  final TextEditingController _idBuahController = TextEditingController();
  final TextEditingController _beratController = TextEditingController();
  final FocusNode _idBuahFocusNode = FocusNode();
  final FocusNode _beratFocusNode = FocusNode();

  // Lot Summary
  int _totalItems = 0;
  double _totalBerat = 0.0;
  List<Map<String, dynamic>> _scannedItems = [];

  bool _isProcessing = false;

  @override
  void dispose() {
    _idBuahController.dispose();
    _beratController.dispose();
    _idBuahFocusNode.dispose();
    _beratFocusNode.dispose();
    super.dispose();
  }

  Future<void> _createLot() async {
    // Validation
    if (_selectedJenisDurianId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jenis durian terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedKondisi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kondisi buah terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final request = CreateLotRequest(
        jenisDurianId: _selectedJenisDurianId!,
        kondisiBuah: _selectedKondisi!,
      );

      final response = await ref
          .read(createLotControllerProvider.notifier)
          .createLot(request);

      if (response == null) {
        throw Exception('Gagal membuat lot');
      }

      setState(() {
        _createdLotId = response.id;
        _createdLotKode = response.kode;
        _stage = 'scanning';
        _isProcessing = false;
      });

      // Auto focus to first field
      Future.delayed(const Duration(milliseconds: 300), () {
        _idBuahFocusNode.requestFocus();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lot ${response.kode} berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
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

  Future<void> _submitBuahItem() async {
    final idBuah = _idBuahController.text.trim();
    final beratText = _beratController.text.trim();

    // Validation
    if (idBuah.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID Buah tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      _idBuahFocusNode.requestFocus();
      return;
    }

    if (beratText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berat tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      _beratFocusNode.requestFocus();
      return;
    }

    final berat = double.tryParse(beratText);
    if (berat == null || berat <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berat harus berupa angka positif'),
          backgroundColor: Colors.red,
        ),
      );
      _beratFocusNode.requestFocus();
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Simulate API call to add item to lot
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock: Check if buah exists
      // In real implementation, this would call API
      final mockBuahExists = idBuah.startsWith('MSW') ||
          idBuah.startsWith('BHM') ||
          idBuah.startsWith('D24') ||
          idBuah.startsWith('XO');

      if (!mockBuahExists) {
        throw Exception('ID Buah tidak ditemukan');
      }

      // Add to local list
      setState(() {
        _scannedItems.add({
          'idBuah': idBuah,
          'berat': berat,
          'timestamp': DateTime.now(),
        });
        _totalItems++;
        _totalBerat += berat;
        _isProcessing = false;
      });

      // Clear inputs
      _idBuahController.clear();
      _beratController.clear();

      // Focus back to ID field
      _idBuahFocusNode.requestFocus();

      // Show success feedback (subtle)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ $idBuah (${berat}kg) ditambahkan'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _idBuahFocusNode.requestFocus();
    }
  }

  Future<void> _finalizeLot() async {
    if (_totalItems == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal 1 buah sebelum finalisasi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalisasi Lot?'),
        content: Text(
          'Lot $_createdLotKode akan difinalisasi dengan:\n\n'
          '• Total Item: $_totalItems buah\n'
          '• Total Berat: ${_totalBerat.toStringAsFixed(2)} kg\n\n'
          'Status akan berubah menjadi READY TO SEND',
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
            ),
            child: const Text('Finalisasi'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      final request = FinalizeLotRequest(beratAwal: _totalBerat);
      final response = await ref
          .read(finalizeLotControllerProvider.notifier)
          .finalize(_createdLotId!, request);

      if (response == null) {
        throw Exception('Gagal finalisasi lot');
      }

      setState(() => _isProcessing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lot berhasil difinalisasi!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back with delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      }
    } catch (e) {
      setState(() => _isProcessing = false);
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_stage == 'create' ? 'Buat Lot Baru' : 'Lotting Terminal'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _stage == 'create' ? _buildCreateStage() : _buildScanningStage(),
    );
  }

  Widget _buildCreateStage() {
    final jenisDurianAsync = ref.watch(jenisDurianProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.info, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Buat Lot DRAFT baru untuk memulai proses lotting',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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
            data: (jenisList) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedJenisDurianId,
                  hint: const Text('Pilih Jenis Durian'),
                  isExpanded: true,
                  items: jenisList.map((jenis) {
                    return DropdownMenuItem<String>(
                      value: jenis.id,
                      child: Text(jenis.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedJenisDurianId = value);
                  },
                ),
              ),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Error loading jenis'),
          ),
          const SizedBox(height: 20),

          // Kondisi Buah
          const Text(
            'Kondisi Buah',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedKondisi,
                hint: const Text('Pilih Kondisi'),
                isExpanded: true,
                items: _kondisiOptions.map((kondisi) {
                  return DropdownMenuItem<String>(
                    value: kondisi['value'],
                    child: Text(kondisi['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedKondisi = value);
                },
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Create Button
          ElevatedButton(
            onPressed: _isProcessing ? null : _createLot,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Buat Lot DRAFT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningStage() {
    return Column(
      children: [
        // Lot Info Header (Compact)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.package,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _createdLotKode ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'DRAFT',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Compact Summary
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_totalItems item',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    '${_totalBerat.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ID Buah Field
                const Text(
                  'ID Buah',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _idBuahController,
                  focusNode: _idBuahFocusNode,
                  enabled: !_isProcessing,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Scan ID Buah',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(LucideIcons.scan, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (_) {
                    _beratFocusNode.requestFocus();
                  },
                ),
                const SizedBox(height: 12),

                // Berat Field
                const Text(
                  'Berat (Kg)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _beratController,
                  focusNode: _beratFocusNode,
                  enabled: !_isProcessing,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Berat (kg)',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(LucideIcons.scale, size: 20),
                    suffixText: 'kg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (_) {
                    _submitBuahItem();
                  },
                ),
                const SizedBox(height: 12),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _submitBuahItem,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(LucideIcons.plus, size: 18),
                    label: const Text(
                      'Tambah (Enter)',
                      style: TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Scanned Items List (in scrollable area)
                if (_scannedItems.isNotEmpty) ...[
                  const Text(
                    'Item yang sudah dipindai',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _scannedItems.length,
                    itemBuilder: (context, index) {
                      final item =
                          _scannedItems[_scannedItems.length - 1 - index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Text(
                              '${_scannedItems.length - index}',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            item['idBuah'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Text(
                            '${item['berat']} kg',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 100), // Extra space for bottom button
                ] else ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.scanLine,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada item yang dipindai',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Extra space for bottom button
                ],
              ],
            ),
          ),
        ),

        // Done Button (Fixed at bottom)
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
              onPressed: _isProcessing ? null : _finalizeLot,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Done - Finalisasi Lot',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
