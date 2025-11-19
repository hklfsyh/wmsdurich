import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wms_durich/core/constants/asset_paths.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/shared/models/warehouse_model.dart';
import 'package:wms_durich/shared/widgets/app_notification.dart';

const List<String> dummyFruitIds = [
  'BT0202 (Black Thorn)',
  'MV0101 (Monthong)',
  'MK0303 (Musang King)'
];

class AddWarehouseTab extends StatefulWidget {
  const AddWarehouseTab({super.key});

  @override
  State<AddWarehouseTab> createState() => _AddWarehouseTabState();
}

class _AddWarehouseTabState extends State<AddWarehouseTab> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  // State untuk Dropdown
  String? _selectedFruitId;
  DurianCondition? _selectedCondition;

  // State untuk validasi error
  String? _fruitIdError;
  String? _conditionError;
  String? _weightError;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      _fruitIdError = _selectedFruitId == null ? 'Pilih ID Buah' : null;
      _conditionError = _selectedCondition == null ? 'Pilih Kondisi' : null;
      final weight = double.tryParse(_weightController.text);
      _weightError = (weight == null || weight <= 0)
          ? 'Masukkan berat dalam angka yang valid (> 0)'
          : null;
    });
  }

  void _increaseWeight() {
    double currentWeight = double.tryParse(_weightController.text) ?? 0.0;
    setState(() {
      currentWeight += 0.1;
      _weightController.text = currentWeight.toStringAsFixed(1);
    });
  }

  void _decreaseWeight() {
    double currentWeight = double.tryParse(_weightController.text) ?? 0.0;
    setState(() {
      if (currentWeight > 0.1) {
        currentWeight -= 0.1;
        _weightController.text = currentWeight.toStringAsFixed(1);
      } else {
        _weightController.text = '0.0';
      }
    });
  }

  void _handleSave() {
    _validateFields();
    if (_fruitIdError == null &&
        _conditionError == null &&
        _weightError == null) {
      Navigator.of(context).pop();
      AppNotification.show(
        context,
        message: 'Data warehouse baru berhasil ditambahkan',
        type: NotificationType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: 24.0, vertical: 0), // Padding disesuaikan
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field ID Warehouse (Auto Generated)
            _buildReadOnlyField('ID Warehouse', 'AUTO GENERATED'),
            const SizedBox(height: 16),

            // Input ID Buah (Dropdown)
            const Text('ID Buah',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildDropdown(
              hint: 'Pilih buah',
              value: _selectedFruitId,
              items: dummyFruitIds,
              onChanged: (newValue) {
                setState(() {
                  _selectedFruitId = newValue;
                  _fruitIdError = null; // Clear error saat user memilih
                });
              },
              error: _fruitIdError,
            ),
            const SizedBox(height: 20),

            // Input Kondisi (Dropdown)
            const Text('Kondisi',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildConditionDropdown(
              hint: 'Pilih kondisi',
              value: _selectedCondition,
              onChanged: (newValue) {
                setState(() {
                  _selectedCondition = newValue;
                  _conditionError = null; // Clear error saat user memilih
                });
              },
              error: _conditionError,
            ),
            const SizedBox(height: 20),

            // Input Berat
            const Text('Berat saat ini (kg)',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _weightError = null; // Clear error saat user mengetik
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Contoh: 2.5',
                    errorText: null, // Tidak tampilkan error di dalam field
                    suffixIcon: SizedBox(
                      width: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _increaseWeight,
                            child: const Icon(Icons.keyboard_arrow_up,
                                size: 20, color: AppColors.textPlaceholder),
                          ),
                          GestureDetector(
                            onTap: _decreaseWeight,
                            child: const Icon(Icons.keyboard_arrow_down,
                                size: 20, color: AppColors.textPlaceholder),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_weightError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text(
                      _weightError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),

            // Tombol Aksi (Batal & Tambah)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: AppColors.textPlaceholder),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.black,
                    ),
                    child: const Text('Batal',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      elevation: 0,
                    ),
                    child: const Text('Tambah',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 30), // Padding bawah agar tombol tidak menempel
          ],
        ),
      ),
    );
  }

  Widget _buildConditionDropdown({
    required String hint,
    DurianCondition? value,
    required Function(DurianCondition?) onChanged,
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
            child: DropdownButton<DurianCondition>(
              isExpanded: true,
              value: value,
              icon: Image.asset(AssetPaths.downGray, height: 16),
              hint: Text(hint),
              onChanged: onChanged,
              items: DurianCondition.values.map((DurianCondition cond) {
                final data = DurianConditionData.fromCondition(cond);
                return DropdownMenuItem<DurianCondition>(
                  value: cond,
                  child: Text(data.label),
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
              icon: Image.asset(AssetPaths.downGray, height: 16),
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

  // Helper Widget untuk Field Read-Only (Sama seperti Edit Modal)
  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
