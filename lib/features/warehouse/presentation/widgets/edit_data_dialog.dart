import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wms_durich/core/constants/asset_paths.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/shared/models/warehouse_model.dart';

const List<DurianCondition> conditionOptions = [
  DurianCondition.bagus,
  DurianCondition.busuk,
  DurianCondition.hancur,
  DurianCondition.hilang,
];

class EditDataDialog extends StatefulWidget {
  final WarehouseModel item;
  final Function(DurianCondition, double) onSave;

  const EditDataDialog({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<EditDataDialog> createState() => _EditDataDialogState();
}

class _EditDataDialogState extends State<EditDataDialog> {
  final _formKey = GlobalKey<FormState>();
  late DurianCondition _selectedCondition;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _selectedCondition = widget.item.condition;
    _weightController =
        TextEditingController(text: widget.item.weightKg.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
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
    if (_formKey.currentState!.validate()) {
      double currentWeight = double.tryParse(_weightController.text) ?? 0.0;
      final newWeight = double.parse(currentWeight.toStringAsFixed(1));
      widget.onSave(_selectedCondition, newWeight);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Edit Data Warehouse',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Image.asset(AssetPaths.closeBlack,
                                height: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildReadOnlyField(
                          'ID Warehouse', widget.item.warehouseId),
                      const SizedBox(height: 16),
                      _buildReadOnlyField('ID Buah', widget.item.fruitId),
                      const SizedBox(height: 16),
                      _buildReadOnlyField('Nama Buah', widget.item.name),
                      const SizedBox(height: 24),
                      const Text('Kondisi',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: AppColors.fieldBackground,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<DurianCondition>(
                            isExpanded: true,
                            value: _selectedCondition,
                            icon:
                                Image.asset(AssetPaths.downGray, height: 16),
                            onChanged: (DurianCondition? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCondition = newValue;
                                });
                              }
                            },
                            items: conditionOptions
                                .map<DropdownMenuItem<DurianCondition>>(
                                    (DurianCondition value) {
                              final data =
                                  DurianConditionData.fromCondition(value);
                              return DropdownMenuItem<DurianCondition>(
                                value: value,
                                child: Text(data.label),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Berat saat ini (kg)',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (value) {
                          final weight = double.tryParse(value ?? '');
                          if (weight == null || weight <= 0) {
                            return 'Masukkan berat dalam angka yang valid (> 0)';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Contoh: 2.5',
                          suffixIcon: SizedBox(
                            width: 40,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _increaseWeight,
                                  child: const Icon(Icons.keyboard_arrow_up,
                                      size: 20,
                                      color: AppColors.textPlaceholder),
                                ),
                                GestureDetector(
                                  onTap: _decreaseWeight,
                                  child: const Icon(Icons.keyboard_arrow_down,
                                      size: 20,
                                      color: AppColors.textPlaceholder),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                side: const BorderSide(
                                    color: AppColors.textPlaceholder),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.black,
                              ),
                              child: const Text('Batal',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
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
                              child: const Text('Simpan',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            '$value (Tidak dapat diubah)',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
