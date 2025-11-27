import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/presentation/add_lot_stock_proses_page.dart';
import 'package:wms_durich/features/warehouse/presentation/lot_in_process_page.dart';

// Mock Data - Struktur mirip dengan BuahItem dari Add Buah
class BuahBelumSortir {
  final String id;
  final String blok;
  final String jenis;
  final DateTime timestamp;
  final String keranjangId;
  bool isSelected;

  BuahBelumSortir({
    required this.id,
    required this.blok,
    required this.jenis,
    required this.timestamp,
    required this.keranjangId,
    this.isSelected = false,
  });
}

class AddLotStockPage extends StatefulWidget {
  const AddLotStockPage({super.key});

  @override
  State<AddLotStockPage> createState() => _AddLotStockPageState();
}

class _AddLotStockPageState extends State<AddLotStockPage> {
  final TextEditingController _searchController = TextEditingController();

  // Mock data buah belum disortir (simulasi dari Add Buah)
  final List<BuahBelumSortir> _allBuah = [
    BuahBelumSortir(
      id: 'B010000-MK001',
      blok: 'B01',
      jenis: 'MK',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      keranjangId: 'KERANJANG-A',
    ),
    BuahBelumSortir(
      id: 'B010000-MK002',
      blok: 'B01',
      jenis: 'MK',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      keranjangId: 'KERANJANG-A',
    ),
    BuahBelumSortir(
      id: 'B010000-MK003',
      blok: 'B01',
      jenis: 'MK',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      keranjangId: 'KERANJANG-A',
    ),
    BuahBelumSortir(
      id: 'B020000-BT001',
      blok: 'B02',
      jenis: 'BT',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      keranjangId: 'KERANJANG-B',
    ),
    BuahBelumSortir(
      id: 'B020000-BT002',
      blok: 'B02',
      jenis: 'BT',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      keranjangId: 'KERANJANG-B',
    ),
    BuahBelumSortir(
      id: 'B030000-F0001001',
      blok: 'B03',
      jenis: 'F0001',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      keranjangId: 'KERANJANG-C',
    ),
    BuahBelumSortir(
      id: 'B030000-F0001002',
      blok: 'B03',
      jenis: 'F0001',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      keranjangId: 'KERANJANG-C',
    ),
    BuahBelumSortir(
      id: 'B040000-F0002001',
      blok: 'B04',
      jenis: 'F0002',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      keranjangId: 'KERANJANG-D',
    ),
    BuahBelumSortir(
      id: 'B010000-MK004',
      blok: 'B01',
      jenis: 'MK',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      keranjangId: 'KERANJANG-A',
    ),
    BuahBelumSortir(
      id: 'B010000-MK005',
      blok: 'B01',
      jenis: 'MK',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      keranjangId: 'KERANJANG-A',
    ),
    BuahBelumSortir(
      id: 'B020000-BT003',
      blok: 'B02',
      jenis: 'BT',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      keranjangId: 'KERANJANG-B',
    ),
    BuahBelumSortir(
      id: 'B030000-F0001003',
      blok: 'B03',
      jenis: 'F0001',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      keranjangId: 'KERANJANG-C',
    ),
  ];

  List<BuahBelumSortir> _filteredBuah = [];
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _filteredBuah = List.from(_allBuah);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBuah(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBuah = List.from(_allBuah);
      } else {
        _filteredBuah = _allBuah.where((buah) {
          return buah.id.toLowerCase().contains(query.toLowerCase()) ||
              buah.blok.toLowerCase().contains(query.toLowerCase()) ||
              buah.jenis.toLowerCase().contains(query.toLowerCase()) ||
              buah.keranjangId.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      for (var buah in _filteredBuah) {
        buah.isSelected = _selectAll;
      }
    });
  }

  void _toggleItemSelection(int index, bool? value) {
    setState(() {
      _filteredBuah[index].isSelected = value ?? false;

      // Update select all status
      _selectAll = _filteredBuah.every((buah) => buah.isSelected);
    });
  }

  int get _selectedCount {
    return _filteredBuah.where((buah) => buah.isSelected).length;
  }

  void _prosesToNextPage() {
    final selectedBuah =
        _filteredBuah.where((buah) => buah.isSelected).toList();

    if (selectedBuah.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 buah untuk melanjutkan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Cek konsistensi jenis sebelum navigate
    final jenisSet = selectedBuah.map((b) => b.jenis).toSet();

    if (jenisSet.length > 1) {
      // Ada lebih dari 1 jenis - tampilkan warning dan jangan navigate
      _showJenisWarningDialog(jenisSet.toList());
      return;
    }

    // Navigate ke halaman Add Lot Stock Proses (halaman kedua)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLotStockProsesPage(
          selectedBuah: selectedBuah,
        ),
      ),
    );
  }

  void _showJenisWarningDialog(List<String> jenisList) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.alertTriangle,
                  color: AppColors.orangeDark, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Peringatan!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terdapat lebih dari satu jenis buah yang dipilih:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.orangeDark.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: jenisList
                    .map((jenis) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(LucideIcons.tag,
                                  size: 16, color: AppColors.orangeDark),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.orangeDark,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  jenis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Harap pastikan hanya memilih buah dengan jenis yang sama untuk satu lot.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Kembali & Pilih Ulang',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Lot Stock'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Jumlah Buah Belum Sortir
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.package, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Buah Belum Sortir',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_allBuah.length} Buah',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.blueDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_selectedCount dipilih',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterBuah,
              decoration: InputDecoration(
                hintText: 'Cari ID, Blok, Jenis, atau Keranjang...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _filterBuah('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Select All Checkbox
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Checkbox(
                  value: _selectAll,
                  onChanged: _toggleSelectAll,
                  activeColor: AppColors.primary,
                ),
                const Text(
                  'Pilih Semua',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  '${_filteredBuah.length} item',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List Buah Belum Sortir (Scrollable)
          Expanded(
            child: _filteredBuah.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.searchX,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada data ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredBuah.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final buah = _filteredBuah[index];
                      return _buildBuahItem(buah, index);
                    },
                  ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                // Tombol List Lot In-Process
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LotInProcessPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.blueDark, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(LucideIcons.packageOpen,
                        size: 18, color: AppColors.blueDark),
                    label: Text(
                      'List\nIn-Process',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blueDark,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Proses Buah
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _selectedCount > 0 ? _prosesToNextPage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade500,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.arrowRight, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _selectedCount > 0
                                ? 'Proses $_selectedCount Buah'
                                : 'Pilih Buah',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuahItem(BuahBelumSortir buah, int index) {
    return InkWell(
      onTap: () => _toggleItemSelection(index, !buah.isSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: buah.isSelected,
              onChanged: (value) => _toggleItemSelection(index, value),
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 12),

            // Item Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID dan Keranjang
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          buah.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orangeLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          buah.keranjangId,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.orangeDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Blok, Jenis, dan Timestamp
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Blok ${buah.blok}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(LucideIcons.tag, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        buah.jenis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(LucideIcons.clock,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(buah.timestamp),
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
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h yang lalu';
    } else {
      return '${difference.inDays}d yang lalu';
    }
  }
}
