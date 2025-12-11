import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/data/models/tujuan_pengiriman_model.dart';
import 'package:wms_durich/features/warehouse/data/repositories/tujuan_pengiriman_repository.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/shipment_provider.dart';

class CreateShipmentDialog extends ConsumerStatefulWidget {
  const CreateShipmentDialog({super.key});

  @override
  ConsumerState<CreateShipmentDialog> createState() =>
      _CreateShipmentDialogState();
}

class _CreateShipmentDialogState extends ConsumerState<CreateShipmentDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTipe;
  TujuanPengirimanModel? _selectedTujuan;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  final List<String> _tipeOptions = ['internal', 'external'];
  
  // Local state for dropdown to avoid affecting global list
  List<TujuanPengirimanModel> _tujuanList = [];
  bool _isLoadingTujuan = false;

  @override
  void initState() {
    super.initState();
    _loadTujuan();
  }
  
  Future<void> _loadTujuan({String? tipe}) async {
    setState(() => _isLoadingTujuan = true);
    try {
      final repository = ref.read(tujuanPengirimanRepositoryProvider);
      final list = await repository.getTujuanPengirimanList(tipe: tipe);
      
      if (mounted) {
        setState(() {
          _tujuanList = list;
          _isLoadingTujuan = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTujuan = false);
      }
      debugPrint('Error loading tujuan: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  void _onTipeChanged(String? newValue) {
    setState(() {
      _selectedTipe = newValue;
      _selectedTujuan = null; // Reset selected destination
    });
    
    // Load local list
    _loadTujuan(tipe: newValue);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createShipment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final tglKirim = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      final shipment = await ref.read(shipmentProvider.notifier).createShipment(
            tujuanId: _selectedTujuan?.id ?? '',
            tglKirim: tglKirim,
          );

      if (mounted) {
        Navigator.pop(context, shipment);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat pengiriman: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(LucideIcons.truck, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Buat Pengiriman Baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Isi data pengiriman di bawah ini',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tipe Tujuan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTipe,
                    decoration: InputDecoration(
                      hintText: 'Pilih Tipe (Opsional)',
                      prefixIcon: const Icon(LucideIcons.filter),
                      filled: true,
                      fillColor: AppColors.fieldBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Semua Tipe'),
                      ),
                      ..._tipeOptions.map((tipe) {
                        return DropdownMenuItem<String>(
                          value: tipe,
                          child: Text(tipe),
                        );
                      }),
                    ],
                    onChanged: _onTipeChanged,
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Tujuan Pengiriman',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingTujuan)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.fieldBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Memuat data tujuan...'),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<TujuanPengirimanModel>(
                      value: _selectedTujuan,
                      decoration: InputDecoration(
                        hintText: 'Pilih Tujuan Pengiriman',
                        prefixIcon: const Icon(LucideIcons.mapPin),
                        filled: true,
                        fillColor: AppColors.fieldBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                      ),
                      items: _tujuanList.map((tujuan) {
                        return DropdownMenuItem<TujuanPengirimanModel>(
                          value: tujuan,
                          child: Text(tujuan.nama),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTujuan = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Tujuan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tanggal & Waktu Kirim',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.fieldBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.calendar,
                                    color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  dateFormat.format(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: _selectTime,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.fieldBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.clock,
                                    color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  timeFormat.format(DateTime(
                                    2000,
                                    1,
                                    1,
                                    _selectedTime.hour,
                                    _selectedTime.minute,
                                  )),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createShipment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.plus, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Buat Draft Pengiriman',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
}
