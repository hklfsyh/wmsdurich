import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/data/models/buah_raw_models.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/buah_raw_provider.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/master_data_provider.dart';
import 'package:wms_durich/shared/widgets/app_notification.dart';
import 'package:intl/intl.dart';

class AddBuahPage extends ConsumerStatefulWidget {
  const AddBuahPage({super.key});

  @override
  ConsumerState<AddBuahPage> createState() => _AddBuahPageState();
}

class _AddBuahPageState extends ConsumerState<AddBuahPage> {
  // Selected IDs (Value for Logic)
  String? _selectedPohonId;
  String? _selectedJenisId;

  final TextEditingController _quantityController =
      TextEditingController(text: '1');

  // Error states
  String? _pohonError;
  String? _jenisError;
  String? _quantityError;

  // Data list (max 10 items displayed)
  final List<BuahRawItem> _dataList = [];

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    int currentQty = int.tryParse(_quantityController.text) ?? 1;
    setState(() {
      _quantityController.text = (currentQty + 1).toString();
    });
  }

  void _decrementQuantity() {
    int currentQty = int.tryParse(_quantityController.text) ?? 1;
    if (currentQty > 1) {
      setState(() {
        _quantityController.text = (currentQty - 1).toString();
      });
    }
  }

  Future<void> _validateAndAddData() async {
    setState(() {
      _pohonError = _selectedPohonId == null ? 'Pilih Blok' : null;
      _jenisError = _selectedJenisId == null ? 'Pilih Jenis' : null;

      final qty = int.tryParse(_quantityController.text);
      _quantityError =
          (qty == null || qty < 1) ? 'Quantity harus minimal 1' : null;
    });

    if (_pohonError == null && _jenisError == null && _quantityError == null) {
      // Prepare request
      final quantity = int.parse(_quantityController.text);
      final request = BuahRawBulkRequest(
        tglPanen: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        items: [
          BuahRawBulkItem(
            jenisDurianId: _selectedJenisId!,
            pohonPanenId: _selectedPohonId!,
            jumlah: quantity,
          ),
        ],
      );

      // Call API
      final response = await ref
          .read(createBulkBuahRawControllerProvider.notifier)
          .createBulk(request);

      // Handle Result
      final state = ref.read(createBulkBuahRawControllerProvider);
      
      if (state.hasError) {
         AppNotification.show(
          context,
          message: 'Gagal menyimpan data: ${state.error}',
          type: NotificationType.error,
        );
      } else if (response != null) {
        _addDataFromResponse(response);
        
        // Refresh warehouse statistics
        ref.invalidate(warehouseDataProvider);
        // Refresh unsorted fruits list for add lot page
        ref.invalidate(unsortedBuahProvider);
      }
    }
  }

  void _addDataFromResponse(BuahRawBulkResponse response) {
    setState(() {
      // Add items from response to the list
      for (var item in response.items) {
        _dataList.insert(0, item);
      }

      // Limit display to 10 most recent items
      if (_dataList.length > 10) {
        _dataList.removeRange(10, _dataList.length);
      }
    });

    AppNotification.show(
      context,
      message: '${response.totalInserted} data berhasil ditambahkan',
      type: NotificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pohonAsync = ref.watch(pohonProvider);
    final jenisAsync = ref.watch(jenisDurianProvider);
    final createResult = ref.watch(createBulkBuahRawControllerProvider);
    final isLoading = createResult.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Buah'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown Blok (Real Data - using Pohon)
            const Text('Blok',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            pohonAsync.when(
              data: (pohonList) => _buildDropdown(
                hint: 'Pilih Blok',
                value: _selectedPohonId,
                items: pohonList.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(p.kodeLengkap),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPohonId = value;
                    _pohonError = null;
                  });
                },
                error: _pohonError,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => Text('Error loading pohon: $err', style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),

            // Dropdown Jenis (Real Data)
            const Text('Jenis',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            jenisAsync.when(
              data: (jenisList) => _buildDropdown(
                hint: 'Pilih Jenis',
                value: _selectedJenisId,
                items: jenisList.map((j) => DropdownMenuItem(
                  value: j.id,
                  child: Text(j.displayName),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedJenisId = value;
                    _jenisError = null;
                  });
                },
                error: _jenisError,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => Text('Error loading jenis: $err', style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),

            // Input Quantity
            const Text('Quantity',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    setState(() {
                      _quantityError = null;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Jumlah buah',
                    errorText: null,
                    suffixIcon: SizedBox(
                      width: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _incrementQuantity,
                            child: const Icon(Icons.keyboard_arrow_up,
                                size: 20, color: AppColors.textPlaceholder),
                          ),
                          GestureDetector(
                            onTap: _decrementQuantity,
                            child: const Icon(Icons.keyboard_arrow_down,
                                size: 20, color: AppColors.textPlaceholder),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_quantityError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text(
                      _quantityError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // List Item Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('List Item',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Menampilkan ${_dataList.length} dari 10 item terakhir',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),

            // List Item (Scrollable)
            Expanded(
              child: _dataList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.package,
                              size: 48, color: AppColors.textPlaceholder),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada data\nKlik tombol "Catat" untuk menambah',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.fieldBackground, width: 1.5),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _dataList.length,
                        separatorBuilder: (context, index) => const Divider(
                            height: 16, color: AppColors.fieldBackground),
                        itemBuilder: (context, index) {
                          final item = _dataList[index];
                          return _buildListItem(item);
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Button Catat
            ElevatedButton.icon(
              onPressed: isLoading ? null : _validateAndAddData,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.save,
                      color: AppColors.white, size: 20),
              label: Text(isLoading ? 'Menyimpan...' : 'Catat',
                  style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(8.0),
            border: error != null
                ? Border.all(color: Theme.of(context).colorScheme.error)
                : null,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: const Icon(LucideIcons.chevronDown, size: 20),
              hint: Text(hint),
              onChanged: onChanged,
              items: items,
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildListItem(BuahRawItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Icon Badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child:
                const Icon(LucideIcons.package, color: Colors.green, size: 16),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.kodeBuah,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Jenis: ${item.jenisDurian.displayName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lokasi: ${item.lokasiPanen.kodeLengkap}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
