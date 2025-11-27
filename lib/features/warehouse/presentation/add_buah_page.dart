import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/shared/widgets/app_notification.dart';

// Mock Data
const List<String> dummyBlok = ['B01', 'B02', 'B03', 'B04'];
const List<String> dummyJenis = ['MK', 'BT', 'F0001', 'F0002'];

class BuahItem {
  final String id;
  final String blok;
  final String jenis;
  final DateTime timestamp;
  final String keranjangId;

  BuahItem({
    required this.id,
    required this.blok,
    required this.jenis,
    required this.timestamp,
    required this.keranjangId,
  });
}

class AddBuahPage extends StatefulWidget {
  const AddBuahPage({super.key});

  @override
  State<AddBuahPage> createState() => _AddBuahPageState();
}

class _AddBuahPageState extends State<AddBuahPage> {
  String? _selectedBlok;
  String? _selectedJenis;
  final TextEditingController _quantityController =
      TextEditingController(text: '1');

  // Error states
  String? _blokError;
  String? _jenisError;
  String? _quantityError;

  // Data list (max 10 items displayed)
  final List<BuahItem> _dataList = [];

  // Counter untuk ID
  int _idCounter = 1;

  // Keranjang tracking
  String _currentKeranjangId = 'KERANJANG-A';
  String? _lastJenis;

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

  void _validateAndAddData() {
    setState(() {
      _blokError = _selectedBlok == null ? 'Pilih Blok' : null;
      _jenisError = _selectedJenis == null ? 'Pilih Jenis' : null;

      final qty = int.tryParse(_quantityController.text);
      _quantityError =
          (qty == null || qty < 1) ? 'Quantity harus minimal 1' : null;
    });

    if (_blokError == null && _jenisError == null && _quantityError == null) {
      _addData();
    }
  }

  void _addData() {
    final quantity = int.tryParse(_quantityController.text) ?? 1;

    // Cek apakah jenis berubah, jika ya buat keranjang baru
    if (_lastJenis != null && _lastJenis != _selectedJenis) {
      // Increment keranjang ID
      String lastChar = _currentKeranjangId.split('-').last;
      String nextChar = String.fromCharCode(lastChar.codeUnitAt(0) + 1);
      _currentKeranjangId = 'KERANJANG-$nextChar';
    }

    setState(() {
      // Tambahkan data sejumlah quantity
      for (int i = 0; i < quantity; i++) {
        String newId =
            '${_selectedBlok}0000-${_selectedJenis}00${_idCounter.toString().padLeft(2, '0')}';

        _dataList.insert(
            0,
            BuahItem(
              id: newId,
              blok: _selectedBlok!,
              jenis: _selectedJenis!,
              timestamp: DateTime.now(),
              keranjangId: _currentKeranjangId,
            ));

        _idCounter++;
      }

      // Simpan jenis terakhir
      _lastJenis = _selectedJenis;

      // Batasi tampilan hanya 10 item terbaru
      if (_dataList.length > 10) {
        _dataList.removeRange(10, _dataList.length);
      }
    });

    AppNotification.show(
      context,
      message: '$quantity data berhasil ditambahkan ke $_currentKeranjangId',
      type: NotificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Dropdown Blok
            const Text('Blok',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _buildDropdown(
              hint: 'Pilih Blok',
              value: _selectedBlok,
              items: dummyBlok,
              onChanged: (value) {
                setState(() {
                  _selectedBlok = value;
                  _blokError = null;
                });
              },
              error: _blokError,
            ),
            const SizedBox(height: 16),

            // Dropdown Jenis
            const Text('Jenis',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _buildDropdown(
              hint: 'Pilih Jenis',
              value: _selectedJenis,
              items: dummyJenis,
              onChanged: (value) {
                setState(() {
                  _selectedJenis = value;
                  _jenisError = null;
                });
              },
              error: _jenisError,
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

            // Info Keranjang
            if (_lastJenis != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Data saat ini masuk ke: $_currentKeranjangId\nJenis terakhir: $_lastJenis',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Button Catat
            ElevatedButton.icon(
              onPressed: _validateAndAddData,
              icon: const Icon(LucideIcons.save,
                  color: AppColors.white, size: 20),
              label: const Text('Catat',
                  style: TextStyle(
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
    required List<String> items,
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
              items: items.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              }).toList(),
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

  Widget _buildListItem(BuahItem item) {
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
                  item.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Blok: ${item.blok} | Jenis: ${item.jenis}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Keranjang Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Text(
              item.keranjangId.split('-').last,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
