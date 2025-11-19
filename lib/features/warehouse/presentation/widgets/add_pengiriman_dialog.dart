import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wms_durich/core/constants/asset_paths.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/shared/models/warehouse_model.dart';
import 'package:wms_durich/shared/widgets/app_notification.dart';

const List<String> dummyStores = [
  'Store A (Jakarta)',
  'Store B (Bandung)',
  'Store C (Surabaya)'
];

final List<WarehouseModel> latestWarehouseData =
    WarehouseModel.dummyData.take(4).toList();

class AddPengirimanDialog extends StatefulWidget {
  const AddPengirimanDialog({super.key});

  @override
  State<AddPengirimanDialog> createState() => _AddPengirimanDialogState();
}

class _AddPengirimanDialogState extends State<AddPengirimanDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStore;
  final TextEditingController _jumlahController =
      TextEditingController(text: '1');

  // Total item yang tersedia (berdasarkan data dummy terbaru)
  final int maxAvailableItems = latestWarehouseData.length;

  // State untuk validasi error
  String? _storeError;
  String? _jumlahError;

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }

  // Stepper Logic (disederhanakan untuk input jumlah item)
  void _updateJumlah(int delta) {
    int currentJumlah = int.tryParse(_jumlahController.text) ?? 0;
    int newJumlah = currentJumlah + delta;

    if (newJumlah >= 1 && newJumlah <= maxAvailableItems) {
      setState(() {
        _jumlahController.text = newJumlah.toString();
      });
    } else if (newJumlah < 1) {
      _jumlahController.text = '1';
    } else {
      _jumlahController.text = maxAvailableItems.toString();
    }
  }

  void _handleSave() {
    // Validasi manual
    final jumlahKirim = int.tryParse(_jumlahController.text) ?? 0;

    setState(() {
      _storeError = _selectedStore == null ? 'Pilih Store Tujuan' : null;
      _jumlahError = (jumlahKirim < 1 || jumlahKirim > maxAvailableItems)
          ? 'Jumlah harus antara 1 sampai $maxAvailableItems'
          : null;
    });

    if (_storeError == null && _jumlahError == null) {
      Navigator.of(context).pop();

      AppNotification.show(
        context,
        message: 'Berhasil mengirim $jumlahKirim item ke $_selectedStore',
        type: NotificationType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int jumlahKirim = int.tryParse(_jumlahController.text) ?? 0;

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
                            'Buat Pengiriman',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child:
                                Image.asset(AssetPaths.closeBlack, height: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Pilih store tujuan dan jumlah data yang akan dikirim',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      const Text('Store Tujuan',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      _buildStoreDropdown(),
                      const SizedBox(height: 20),
                      Text('Jumlah (Maksimal $maxAvailableItems data tersedia)',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      _buildJumlahInput(),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.blueLight,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'Info: Data yang dikirim adalah ($jumlahKirim) data terbaru dari warehouse',
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.blueDark),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Preview Data yang Akan Dikirim:',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      if (jumlahKirim > 0)
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 100,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: jumlahKirim,
                            itemBuilder: (context, index) {
                              return _buildPreviewCard(
                                  latestWarehouseData[index]);
                            },
                          ),
                        ),
                      if (jumlahKirim == 0)
                        const Text('Pilih jumlah data untuk melihat preview.',
                            style: TextStyle(color: AppColors.textPlaceholder)),
                      const SizedBox(height: 30),
                      Row(
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
                              child: const Text('Tambah',
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

  Widget _buildJumlahInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _jumlahController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            setState(() {
              _jumlahError = null; // Clear error saat user mengetik
            });
          },
          decoration: InputDecoration(
            hintText: 'Jumlah',
            errorText: null, // Tidak tampilkan error di dalam field
            suffixIcon: SizedBox(
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _updateJumlah(1),
                    child: const Icon(Icons.keyboard_arrow_up,
                        size: 20, color: AppColors.textPlaceholder),
                  ),
                  GestureDetector(
                    onTap: () => _updateJumlah(-1),
                    child: const Icon(Icons.keyboard_arrow_down,
                        size: 20, color: AppColors.textPlaceholder),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_jumlahError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              _jumlahError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStoreDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(8.0),
            border: _storeError != null
                ? Border.all(color: Theme.of(context).colorScheme.error)
                : null,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedStore,
              icon: Image.asset(AssetPaths.downGray, height: 16),
              hint: const Text('Pilih store'),
              onChanged: (newValue) {
                setState(() {
                  _selectedStore = newValue;
                  _storeError = null; // Clear error saat user memilih
                });
              },
              items: dummyStores.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              }).toList(),
            ),
          ),
        ),
        if (_storeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              _storeError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPreviewCard(WarehouseModel item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.fieldBackground),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text('Berat: ${item.weightKg.toStringAsFixed(1)} kg',
                style: const TextStyle(color: AppColors.textSecondary)),
            Text(DateFormat('d MMMM yyyy').format(item.entryDate),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
