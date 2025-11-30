import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/data/models/buah_raw_models.dart';
import 'package:wms_durich/features/warehouse/presentation/add_lot_stock_proses_page.dart';
import 'package:wms_durich/features/warehouse/presentation/lot_in_process_page.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/buah_raw_provider.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/master_data_provider.dart';

class AddLotStockPage extends ConsumerStatefulWidget {
  const AddLotStockPage({super.key});

  @override
  ConsumerState<AddLotStockPage> createState() => _AddLotStockPageState();
}

class _AddLotStockPageState extends ConsumerState<AddLotStockPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  
  // Store full BuahRawItem objects mapped by ID to persist across pages
  final Map<String, BuahRawItem> _selectedItems = {};
  bool _selectAll = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(unsortedBuahParamsProvider.notifier).setSearch(
        query.isEmpty ? null : query,
      );
    });
  }

  void _toggleSelectAll(bool? value, List<BuahRawItem> items) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        for (var item in items) {
          _selectedItems[item.id] = item;
        }
      } else {
        for (var item in items) {
          _selectedItems.remove(item.id);
        }
      }
    });
  }

  void _toggleItemSelection(BuahRawItem item) {
    setState(() {
      if (_selectedItems.containsKey(item.id)) {
        _selectedItems.remove(item.id);
      } else {
        _selectedItems[item.id] = item;
      }
    });
  }

  void _prosesToNextPage() {
    final selectedBuah = _selectedItems.values.toList();

    if (selectedBuah.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 buah untuk melanjutkan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final jenisSet = selectedBuah.map((b) => b.jenisDurian.kode).toSet();

    if (jenisSet.length > 1) {
      _showJenisWarningDialog(jenisSet.toList());
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLotStockProsesPage(
          selectedBuahRaw: selectedBuah,
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
              decoration: const BoxDecoration(
                color: AppColors.orangeLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.alertTriangle,
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
                border: Border.all(color: AppColors.orangeDark.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: jenisList
                    .map((jenis) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.tag,
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
            onPressed: () => Navigator.pop(context),
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
    final buahAsync = ref.watch(unsortedBuahProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Lot Stock'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: buahAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.alertCircle, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Gagal memuat data', style: TextStyle(color: Colors.red[700])),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(unsortedBuahProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (response) => _buildContent(response),
      ),
    );
  }

  Widget _buildContent(UnsortedBuahResponse response) {
    final items = response.data;
    final selectedCount = _selectedItems.length;
    final params = ref.watch(unsortedBuahParamsProvider);
    final jenisDurianAsync = ref.watch(jenisDurianProvider);

    if (items.isNotEmpty) {
      _selectAll = items.every((b) => _selectedItems.containsKey(b.id));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              const Icon(LucideIcons.package, color: AppColors.primary, size: 28),
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
                      '${response.meta.totalData} Buah',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.blueDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$selectedCount dipilih',
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

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari kode buah...',
                    hintStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
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
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: jenisDurianAsync.when(
                    data: (jenisList) => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: params.jenisDurianId,
                        hint: const Text('Semua', style: TextStyle(fontSize: 14)),
                        isExpanded: true,
                        icon: const Icon(LucideIcons.chevronDown, size: 18),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Semua'),
                          ),
                          ...jenisList.map((jenis) => DropdownMenuItem<String>(
                            value: jenis.id,
                            child: Text(
                              jenis.displayName,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                        ],
                        onChanged: (value) {
                          ref.read(unsortedBuahParamsProvider.notifier).setJenisDurianId(value);
                        },
                      ),
                    ),
                    loading: () => const Center(
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (_, __) => const Center(child: Text('Error', style: TextStyle(color: Colors.red, fontSize: 12))),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Select All Checkbox
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Checkbox(
                value: _selectAll && items.isNotEmpty,
                onChanged: (v) => _toggleSelectAll(v, items),
                activeColor: AppColors.primary,
              ),
              const Text(
                'Pilih Semua',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const Spacer(),
              Text(
                '${items.length} item',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // List Buah
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.inbox, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada buah yang belum disortir',
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
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final buah = items[index];
                    return _buildBuahItem(buah);
                  },
                ),
        ),

        // Pagination
        if (response.meta.totalPage > 1) _buildPagination(response.meta),

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
                    side: const BorderSide(color: AppColors.blueDark, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(LucideIcons.packageOpen, size: 18, color: AppColors.blueDark),
                  label: const Text(
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
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: selectedCount > 0 ? () => _prosesToNextPage() : null,
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
                          selectedCount > 0 ? 'Proses $selectedCount Buah' : 'Pilih Buah',
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
    );
  }

  Widget _buildBuahItem(BuahRawItem buah) {
    final isSelected = _selectedItems.containsKey(buah.id);

    return InkWell(
      onTap: () => _toggleItemSelection(buah),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleItemSelection(buah),
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          buah.kodeBuah,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.blueLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          buah.jenisDurian.displayName,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          buah.lokasiPanen.kodeLengkap,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(LucideIcons.clock, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(buah.createdAt),
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

  Widget _buildPagination(PaginationMeta meta) {
    final currentPage = ref.read(unsortedBuahParamsProvider).page;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1
                ? () => ref.read(unsortedBuahParamsProvider.notifier).setPage(currentPage - 1)
                : null,
            icon: const Icon(LucideIcons.chevronLeft),
            iconSize: 20,
          ),
          Text(
            'Halaman $currentPage / ${meta.totalPage}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          IconButton(
            onPressed: currentPage < meta.totalPage
                ? () => ref.read(unsortedBuahParamsProvider.notifier).setPage(currentPage + 1)
                : null,
            icon: const Icon(LucideIcons.chevronRight),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}j lalu';
    } else {
      return '${difference.inDays}h lalu';
    }
  }
}
