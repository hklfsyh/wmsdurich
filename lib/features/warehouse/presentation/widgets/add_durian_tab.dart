import 'package:flutter/material.dart';
import 'package:wms_durich/core/constants/asset_paths.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/shared/widgets/app_notification.dart';

class TreeData {
  final String id;
  final String code;
  final String name;

  const TreeData(this.id, this.code, this.name);
}

// Opsi dummy untuk Dropdown ID Pohon
const List<TreeData> dummyTreeData = [
  // ID, Code, Name
  TreeData('TR001', 'MK', 'Musang King'),
  TreeData('TR002', 'BT', 'Black Thorn'),
  TreeData('TR003', 'MN', 'Monthong'),
];

class AddDurianTab extends StatefulWidget {
  const AddDurianTab({super.key});

  @override
  State<AddDurianTab> createState() => _AddDurianTabState();
}

class _AddDurianTabState extends State<AddDurianTab> {
  final _formKey = GlobalKey<FormState>();
  TreeData? _selectedTree;

  // Data Auto-generated
  String _generatedFruitId = 'AUTO GENERATED';
  String _generatedFruitName = 'AUTO GENERATED';

  // State untuk validasi error
  String? _treeError;

  void _onTreeSelected(TreeData? tree) {
    setState(() {
      _selectedTree = tree;
      _treeError = null; // Clear error saat user memilih
      if (tree != null) {
        // Simulasi logika Auto-Generate: Kode + Nomor Urut Dummy
        _generatedFruitId = '${tree.code}001';
        _generatedFruitName = tree.name;
      } else {
        _generatedFruitId = 'AUTO GENERATED';
        _generatedFruitName = 'AUTO GENERATED';
      }
    });
  }

  void _handleSave() {
    if (_selectedTree == null) {
      setState(() {
        _treeError = 'Pilih ID Pohon';
      });
      return;
    }

    Navigator.of(context).pop();
    AppNotification.show(
      context,
      message: 'Data durian $_generatedFruitId berhasil ditambahkan',
      type: NotificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input ID Pohon (Dropdown)
            const Text('ID Pohon',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildTreeDropdown(
              hint: 'Pilih pohon',
              value: _selectedTree,
              items: dummyTreeData,
              onChanged: _onTreeSelected,
              error: _treeError,
            ),
            const SizedBox(height: 20),

            // Field ID Buah (Auto Generated)
            _buildReadOnlyField('ID Buah', _generatedFruitId),
            const SizedBox(height: 16),

            // Field Nama Buah (Auto Generated)
            _buildReadOnlyField('Nama Buah', _generatedFruitName),
            const SizedBox(height: 30),

            // Tombol Aksi (Batal & Simpan)
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper Widget Dropdown ID Pohon
  Widget _buildTreeDropdown({
    required String hint,
    TreeData? value,
    required List<TreeData> items,
    required Function(TreeData?) onChanged,
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
            child: DropdownButton<TreeData>(
              isExpanded: true,
              value: value,
              icon: Image.asset(AssetPaths.downGray, height: 16),
              hint: Text(hint),
              onChanged: onChanged,
              items: items.map((TreeData data) {
                return DropdownMenuItem<TreeData>(
                  value: data,
                  child: Text('${data.id} (${data.name})'),
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

  // Helper Widget untuk Field Read-Only (Sama seperti Add Warehouse)
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
