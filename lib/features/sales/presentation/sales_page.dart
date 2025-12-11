import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/core/widgets/profile_dropdown.dart';
import 'package:wms_durich/features/sales/data/models/sales_models.dart';
import 'package:wms_durich/features/sales/presentation/providers/sales_provider.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/shipment_provider.dart';
import 'package:wms_durich/features/warehouse/data/models/shipment_models.dart';
import 'package:wms_durich/features/warehouse/data/repositories/shipment_repository.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    ref.read(salesProvider.notifier).loadSales(
      tipeJual: _selectedFilter == 'all' ? null : _selectedFilter
    );
    // Load shipments to resolve destination names and for dropdown
    ref.read(shipmentProvider.notifier).refreshShipments();
  }

  @override
  Widget build(BuildContext context) {
    final salesState = ref.watch(salesProvider);
    final shipments = ref.watch(shipmentProvider).shipments;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Warehouse Management'),
            const SizedBox(width: 8),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          const ProfileDropdown(),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatisticsCards(salesState.sales),
              const SizedBox(height: 24),
              _buildFilterSection(),
              const SizedBox(height: 16),
              if (salesState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (salesState.error != null)
                Center(child: Text('Error: ${salesState.error}'))
              else
                _buildSalesList(salesState.sales, shipments),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSalesDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text(
          'Buat Invoice',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.receipt,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penjualan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kelola invoice penjualan durian',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(List<SalesModel> sales) {
    final totalSales = sales.length;
    final totalRevenue = sales.fold<double>(
      0,
      (sum, sale) => sum + sale.hargaTotal,
    );
    final totalBerat = sales.fold<double>(
      0,
      (sum, sale) => sum + sale.beratTerjual,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Invoice',
            totalSales.toString(),
            LucideIcons.receipt,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Omzet',
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp',
              decimalDigits: 0,
            ).format(totalRevenue),
            LucideIcons.dollarSign,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Berat',
            '${totalBerat.toStringAsFixed(1)} kg',
            LucideIcons.scale,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Kiloan', 'KILOAN'),
                const SizedBox(width: 8),
                _buildFilterChip('Borongan', 'BORONGAN'),
                const SizedBox(width: 8),
                _buildFilterChip('Per Item', 'ITEM'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
          ref.read(salesProvider.notifier).loadSales(
            tipeJual: _selectedFilter == 'all' ? null : _selectedFilter
          );
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildSalesList(List<SalesModel> sales, List<ShipmentModel> shipments) {
    if (sales.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Penjualan (${sales.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...sales.map((sale) => _buildSalesCard(sale, shipments)),
      ],
    );
  }

  Widget _buildSalesCard(SalesModel sale, List<ShipmentModel> shipments) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // Resolve shipment destination name
    String tujuan = 'Unknown Destination';
    try {
      final shipment = shipments.firstWhere((s) => s.id == sale.pengirimanId);
      tujuan = shipment.tujuan;
    } catch (_) {
      tujuan = 'Pengiriman ${sale.pengirimanId}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => _showSalesDetail(sale, tujuan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.receipt,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.id,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pengiriman: ${sale.pengirimanId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildTipeJualBadge(sale.tipeJual),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tujuan,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.scale, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              '${sale.beratTerjual} kg',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          currencyFormat.format(sale.hargaTotal),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(LucideIcons.clock, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(sale.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipeJualBadge(String tipe) {
    Color color;
    Color textColor;
    switch (tipe) {
      case 'KILOAN':
        color = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        break;
      case 'BORONGAN':
        color = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case 'ITEM':
        color = Colors.purple.shade100;
        textColor = Colors.purple.shade700;
        break;
      default:
        color = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tipe,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.receipt, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada data penjualan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Buat invoice penjualan pertama Anda',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSalesDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateSalesDialog(),
    );
  }

  void _showSalesDetail(SalesModel sale, String tujuan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SalesDetailSheet(sale: sale, tujuan: tujuan),
    );
  }
}

class CreateSalesDialog extends ConsumerStatefulWidget {
  const CreateSalesDialog({super.key});

  @override
  ConsumerState<CreateSalesDialog> createState() => _CreateSalesDialogState();
}

class _CreateSalesDialogState extends ConsumerState<CreateSalesDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedShipmentId;
  String _selectedTipeJual = 'KILOAN';
  final _beratController = TextEditingController();
  final _hargaController = TextEditingController();
  
  List<ShipmentModel> _shipments = [];
  bool _isLoadingShipments = false;

  @override
  void initState() {
    super.initState();
    _loadShipments();
  }

  Future<void> _loadShipments() async {
    setState(() => _isLoadingShipments = true);
    try {
      final repository = ref.read(shipmentRepositoryProvider);
      final data = await repository.getShipments(
        type: 'outgoing',
        tujuanType: 'external',
        status: 'SENDING', // Assuming we only want SENDING or SHIPPED. 
        // NOTE: If backend handles filtering multiple statuses, great. 
        // If not, we might need to fetch and filter.
        // Based on user request, endpoint is GET /v1/shipments?type=outgoing&tujuan_type=external
        // It doesn't specify status in the request, but previously we filtered by SENDING/SHIPPED.
        // I will rely on client filtering for status if backend returns everything, or pass status if needed.
        // Let's pass status 'SENDING' for now as logic usually suggests only sending shipments are valid for sales?
        // Or 'SHIPPED'? User said "shipment yang muncul itu shipment yang outgoing dan external".
        // Let's NOT pass status filter to API if not requested, but filter result client side if needed.
        // Actually, user showed response with status "SENDING".
        // Let's just fetch type=outgoing & tujuan_type=external.
      );
      
      // Filter locally for status if needed, or take all.
      // Previous logic was: status == 'SENDING' || status == 'SHIPPED'
      final filtered = data.where((s) => s.status == 'SENDING' || s.status == 'SHIPPED').toList();

      if (mounted) {
        setState(() {
          _shipments = filtered;
          _isLoadingShipments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingShipments = false);
        // Optionally show error
      }
    }
  }

  @override
  void dispose() {
    _beratController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.receipt, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Buat Invoice Penjualan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isLoadingShipments)
                  const Center(child: CircularProgressIndicator())
                else
                  DropdownButtonFormField<String>(
                    value: _selectedShipmentId,
                    decoration: InputDecoration(
                      labelText: 'Pilih Pengiriman',
                      prefixIcon: const Icon(LucideIcons.truck),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _shipments.map((shipment) {
                      return DropdownMenuItem(
                        value: shipment.id,
                        child: Text('${shipment.kode} - ${shipment.tujuan}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedShipmentId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Pilih pengiriman';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTipeJual,
                  decoration: InputDecoration(
                    labelText: 'Tipe Penjualan',
                    prefixIcon: const Icon(LucideIcons.tags),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'KILOAN', child: Text('Kiloan')),
                    DropdownMenuItem(value: 'BORONGAN', child: Text('Borongan')),
                    DropdownMenuItem(value: 'ITEM', child: Text('Per Item')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedTipeJual = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _beratController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Berat Terjual (kg)',
                    hintText: 'Masukkan berat',
                    prefixIcon: const Icon(LucideIcons.scale),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Berat tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Berat harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hargaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Harga Total (Rp)',
                    hintText: 'Masukkan total harga',
                    prefixIcon: const Icon(LucideIcons.dollarSign),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Harga harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Buat Invoice',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(salesProvider.notifier).createSales(
          pengirimanId: _selectedShipmentId!,
          beratTerjual: double.parse(_beratController.text),
          hargaTotal: double.parse(_hargaController.text),
          tipeJual: _selectedTipeJual,
        );
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class SalesDetailSheet extends ConsumerWidget {
  final SalesModel sale;
  final String tujuan;

  const SalesDetailSheet({super.key, required this.sale, required this.tujuan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.receipt, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Penjualan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        sale.id,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoRow('ID Pengiriman', sale.pengirimanId, LucideIcons.truck),
                const SizedBox(height: 12),
                _buildInfoRow('Tujuan', tujuan, LucideIcons.mapPin),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Berat Terjual',
                  '${sale.beratTerjual} kg',
                  LucideIcons.scale,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Total Harga',
                  currencyFormat.format(sale.hargaTotal),
                  LucideIcons.dollarSign,
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Tipe Penjualan', sale.tipeJual, LucideIcons.tags),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Tanggal',
                  dateFormat.format(sale.createdAt),
                  LucideIcons.calendar,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement update dialog
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur edit belum diimplementasikan di UI')),
                          );
                        },
                        icon: const Icon(LucideIcons.edit),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _confirmVoid(context, ref, sale.id);
                        },
                        icon: const Icon(LucideIcons.trash2),
                        label: const Text('Void'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmVoid(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Penjualan?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await ref.read(salesProvider.notifier).voidSales(id);
                if (!context.mounted) return;
                Navigator.pop(context); // Close sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Penjualan berhasil dibatalkan')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal: $e')),
                );
              }
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
