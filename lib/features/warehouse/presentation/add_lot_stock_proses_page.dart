import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/data/models/lot_models.dart';
import 'package:wms_durich/features/warehouse/data/repositories/lot_repository.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/lot_provider.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/master_data_provider.dart';

class AddLotStockProsesPage extends ConsumerStatefulWidget {
  final String? resumeLotId;
  final String? resumeLotKode;

  const AddLotStockProsesPage({
    super.key,
    this.resumeLotId,
    this.resumeLotKode,
  });

  @override
  ConsumerState<AddLotStockProsesPage> createState() =>
      _AddLotStockProsesPageState();
}

class _AddLotStockProsesPageState extends ConsumerState<AddLotStockProsesPage> {
  // Stage: 'create' or 'scanning'
  late String _stage;

  // Create Lot Stage
  String? _selectedJenisDurianId;
  String? _selectedKondisi;
  final _kondisiOptions = [
    {'value': 'A', 'label': 'A - Bagus'},
    {'value': 'B', 'label': 'B - Rusak Sebagian / Bakal Pulping'},
    {'value': 'M', 'label': 'M - Belum Masak'},
    {'value': 'R', 'label': 'R - Reject / Rusak / Busuk'},
  ];

  String? _createdLotId;
  String? _createdLotKode;

  final TextEditingController _pohonKodeController = TextEditingController();
  final TextEditingController _beratController = TextEditingController();
  final FocusNode _pohonKodeFocusNode = FocusNode();
  final FocusNode _beratFocusNode = FocusNode();
  final FocusNode _blokFocusNode = FocusNode();

  String? _selectedBlokId;

  int _totalItems = 0;
  double _totalBerat = 0.0;
  List<LotDetailItem> _scannedItems = [];

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.resumeLotId != null) {
      _stage = 'scanning';
      _createdLotId = widget.resumeLotId;
      _createdLotKode = widget.resumeLotKode;
      // Load existing items
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingLotData();
      });
    } else {
      _stage = 'create';
    }
  }

  Future<void> _loadExistingLotData() async {
    if (_createdLotId == null) return;
    
    setState(() => _isProcessing = true);
    try {
      final repository = ref.read(lotRepositoryProvider);
      final response = await repository.getLotDetail(_createdLotId!);

      setState(() {
        _scannedItems = response.items;
        _totalItems = response.header.currentQty;
        _totalBerat = response.header.currentBerat;
        // Also update code if not provided or different
        _createdLotKode = response.header.kode;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lot data: $e')),
        );
      }
    }
  }


  @override
  void dispose() {
    _pohonKodeController.dispose();
    _beratController.dispose();
    _pohonKodeFocusNode.dispose();
    _beratFocusNode.dispose();
    _blokFocusNode.dispose();
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
        _pohonKodeFocusNode.requestFocus();
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
    final pohonKode = _pohonKodeController.text.trim();
    final beratText = _beratController.text.trim();

    if (pohonKode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pohon Kode tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      _pohonKodeFocusNode.requestFocus();
      return;
    }

    if (_selectedBlokId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Blok harus dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      _blokFocusNode.requestFocus();
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

    if (_createdLotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lot belum dibuat'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await ref.read(addItemsToLotControllerProvider.notifier).addItems(
            _createdLotId!,
            AddItemsToLotRequest(
              pohonKode: pohonKode,
              blokId: _selectedBlokId!,
              berat: berat,
            ),
          );

      // Refresh data from API
      final repository = ref.read(lotRepositoryProvider);
      final response = await repository.getLotDetail(_createdLotId!);

      // Invalidate warehouse data to ensure counts (like raw fruit) are updated in Warehouse Page
      ref.invalidate(warehouseDataProvider);
      
      // Invalidate draft lots list as stats changed
      ref.invalidate(allDraftLotsProvider);

      setState(() {
        _scannedItems = response.items;
        _totalItems = response.header.currentQty;
        _totalBerat = response.header.currentBerat;
        _isProcessing = false;
      });

      _pohonKodeController.clear();
      _beratController.clear();

      _pohonKodeFocusNode.requestFocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ $pohonKode (${berat}kg) ditambahkan'),
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
      _pohonKodeFocusNode.requestFocus();
    }
  }

  Future<void> _removeItem(int index) async {
    final item = _scannedItems[index];
    final buahRawId = item.id;

    if (buahRawId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID item tidak valid.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item?'),
        content: Text('Hapus ${item.kodeBuah}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      final request = RemoveItemFromLotRequest(buahRawId: buahRawId);
      await ref
          .read(removeItemFromLotControllerProvider.notifier)
          .removeItem(_createdLotId!, request);

      // Refresh data from API
      final repository = ref.read(lotRepositoryProvider);
      final response = await repository.getLotDetail(_createdLotId!);

      setState(() {
        _scannedItems = response.items;
        _totalItems = response.header.currentQty;
        _totalBerat = response.header.currentBerat;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item berhasil dihapus'),
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
      final request = FinalizeLotRequest();
      final response = await ref
          .read(finalizeLotControllerProvider.notifier)
          .finalize(_createdLotId!, request);

      if (response == null) {
        throw Exception('Gagal finalisasi lot');
      }

      // Invalidate providers
      ref.invalidate(warehouseDataProvider);
      ref.invalidate(lotDetailProvider(_createdLotId!));
      ref.invalidate(allDraftLotsProvider);
      ref.invalidate(allReadyLotsProvider);

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
                const Text(
                  'Blok',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Consumer(
                  builder: (context, ref, _) {
                    final blokAsync = ref.watch(bloksProvider);
                    return blokAsync.when(
                      data: (bloks) => DropdownButtonFormField<String>(
                        value: _selectedBlokId,
                        focusNode: _blokFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Pilih Blok',
                          hintStyle: const TextStyle(fontSize: 13),
                          prefixIcon: const Icon(LucideIcons.box, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                        items: bloks
                            .map((blok) => DropdownMenuItem<String>(
                                  value: blok.id,
                                  child: Text(
                                    blok.kodeLengkap,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ))
                            .toList(),
                        onChanged: _isProcessing
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedBlokId = value;
                                });
                                _pohonKodeFocusNode.requestFocus();
                              },
                      ),
                      loading: () => DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Loading...',
                          hintStyle: const TextStyle(fontSize: 13),
                          prefixIcon: const Icon(LucideIcons.box, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                        items: const [],
                        onChanged: null,
                      ),
                      error: (err, _) => DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Error loading blok',
                          hintStyle: const TextStyle(fontSize: 13),
                          prefixIcon: const Icon(LucideIcons.box, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                        items: const [],
                        onChanged: null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                const Text(
                  'Pohon Kode',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _pohonKodeController,
                  focusNode: _pohonKodeFocusNode,
                  enabled: !_isProcessing,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Scan Pohon Kode',
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
                            item.kodeBuah,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.jenisDurian,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '${item.asalBlok} • ${item.tglPanen.toString().split(' ')[0]}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
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
                          trailing: IconButton(
                            icon: const Icon(
                              LucideIcons.trash2,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () => _removeItem(_scannedItems.length - 1 - index),
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
