import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/core/widgets/profile_dropdown.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  String _selectedFilter = 'all';
  
  // Demo data
  final List<Map<String, dynamic>> _demoSales = [
    {
      'id': 'SALE_001',
      'pengiriman_id': 'SHP_001',
      'tujuan': 'Toko Buah Segar',
      'berat_terjual': 150.5,
      'harga_total': 25000000,
      'tipe_jual': 'KILOAN',
      'created_at': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 'SALE_002',
      'pengiriman_id': 'SHP_002',
      'tujuan': 'Pasar Sentral',
      'berat_terjual': 300.0,
      'harga_total': 45000000,
      'tipe_jual': 'BORONGAN',
      'created_at': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': 'SALE_003',
      'pengiriman_id': 'SHP_003',
      'tujuan': 'Gudang Medan',
      'berat_terjual': 200.8,
      'harga_total': 32000000,
      'tipe_jual': 'KILOAN',
      'created_at': DateTime.now().subtract(const Duration(days: 3)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Warehouse Management'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.shade300, width: 0.5),
              ),
              child: Text(
                'DEMO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
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
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatisticsCards(),
              const SizedBox(height: 24),
              _buildFilterSection(),
              const SizedBox(height: 16),
              _buildSalesList(),
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

  Widget _buildStatisticsCards() {
    final totalSales = _demoSales.length;
    final totalRevenue = _demoSales.fold<double>(
      0,
      (sum, sale) => sum + (sale['harga_total'] as num).toDouble(),
    );
    final totalBerat = _demoSales.fold<double>(
      0,
      (sum, sale) => sum + (sale['berat_terjual'] as num).toDouble(),
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

  Widget _buildSalesList() {
    final filteredSales = _selectedFilter == 'all'
        ? _demoSales
        : _demoSales.where((s) => s['tipe_jual'] == _selectedFilter).toList();

    if (filteredSales.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Penjualan (${filteredSales.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...filteredSales.map((sale) => _buildSalesCard(sale)),
      ],
    );
  }

  Widget _buildSalesCard(Map<String, dynamic> sale) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => _showSalesDetail(sale),
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
                          sale['id'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pengiriman: ${sale['pengiriman_id']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildTipeJualBadge(sale['tipe_jual']),
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
                            sale['tujuan'],
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
                              '${sale['berat_terjual']} kg',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          currencyFormat.format(sale['harga_total']),
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
                    dateFormat.format(sale['created_at']),
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

  void _showSalesDetail(Map<String, dynamic> sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SalesDetailSheet(sale: sale),
    );
  }
}

class CreateSalesDialog extends StatefulWidget {
  const CreateSalesDialog({super.key});

  @override
  State<CreateSalesDialog> createState() => _CreateSalesDialogState();
}

class _CreateSalesDialogState extends State<CreateSalesDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedShipmentId;
  String _selectedTipeJual = 'KILOAN';
  final _beratController = TextEditingController();
  final _hargaController = TextEditingController();

  // Demo shipment yang sudah SHIPPED
  final List<Map<String, String>> _demoShipments = [
    {'id': 'SHP_004', 'tujuan': 'Toko Berkah'},
    {'id': 'SHP_005', 'tujuan': 'Pasar Modern'},
    {'id': 'SHP_006', 'tujuan': 'Distributor Jaya'},
  ];

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
                DropdownButtonFormField<String>(
                  value: _selectedShipmentId,
                  decoration: InputDecoration(
                    labelText: 'Pilih Pengiriman',
                    prefixIcon: const Icon(LucideIcons.truck),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _demoShipments.map((shipment) {
                    return DropdownMenuItem(
                      value: shipment['id'],
                      child: Text('${shipment['id']} - ${shipment['tujuan']}'),
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice berhasil dibuat (Demo)'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class SalesDetailSheet extends StatelessWidget {
  final Map<String, dynamic> sale;

  const SalesDetailSheet({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
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
                        sale['id'],
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
                _buildInfoRow('ID Pengiriman', sale['pengiriman_id'], LucideIcons.truck),
                const SizedBox(height: 12),
                _buildInfoRow('Tujuan', sale['tujuan'], LucideIcons.mapPin),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Berat Terjual',
                  '${sale['berat_terjual']} kg',
                  LucideIcons.scale,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Total Harga',
                  currencyFormat.format(sale['harga_total']),
                  LucideIcons.dollarSign,
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Tipe Penjualan', sale['tipe_jual'], LucideIcons.tags),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Tanggal',
                  dateFormat.format(sale['created_at']),
                  LucideIcons.calendar,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur edit (Demo)')),
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
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invoice void (Demo)'),
                              backgroundColor: Colors.red,
                            ),
                          );
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
}
