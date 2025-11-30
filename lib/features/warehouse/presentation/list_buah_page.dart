import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/data/models/buah_raw_models.dart';
import 'package:wms_durich/features/warehouse/data/models/master_data_models.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/buah_raw_provider.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/master_data_provider.dart';
import 'package:intl/intl.dart';

class ListBuahPage extends ConsumerStatefulWidget {
  const ListBuahPage({super.key});

  @override
  ConsumerState<ListBuahPage> createState() => _ListBuahPageState();
}

class _ListBuahPageState extends ConsumerState<ListBuahPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Set default filter to today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      ref.read(buahRawParamsProvider.notifier).setFilters(tglPanen: today);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(buahRawParamsProvider.notifier).setSearch(
        value.isEmpty ? null : value,
      );
    });
  }

  void _goToPage(int page) {
    ref.read(buahRawParamsProvider.notifier).setPage(page);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.black,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      ref.read(buahRawParamsProvider.notifier).setTglPanen(formattedDate);
    }
  }

  void _clearDate() {
    _dateController.clear();
    ref.read(buahRawParamsProvider.notifier).setTglPanen(null);
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buahAsync = ref.watch(buahRawProvider);
    final params = ref.watch(buahRawParamsProvider);
    final jenisDurianAsync = ref.watch(jenisDurianProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buah Masuk'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _searchController.clear();
              _dateController.clear();
              ref.read(buahRawParamsProvider.notifier).reset();
            },
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'Reset Filter',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.fieldBackground),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari kode buah...',
                  hintStyle: const TextStyle(color: AppColors.textPlaceholder),
                  prefixIcon: const Icon(LucideIcons.search, color: AppColors.textSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filters Row
            Row(
              children: [
                // Date Filter
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.fieldBackground),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _dateController.text.isEmpty ? 'Tgl Panen' : _dateController.text,
                              style: TextStyle(
                                color: _dateController.text.isEmpty 
                                  ? AppColors.textPlaceholder 
                                  : AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_dateController.text.isNotEmpty)
                            InkWell(
                              onTap: _clearDate,
                              child: const Icon(LucideIcons.x, size: 16, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Jenis Durian Filter
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.fieldBackground),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: jenisDurianAsync.when(
                      data: (jenisList) => DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: params.jenisDurianId,
                          hint: const Text('Jenis', style: TextStyle(color: AppColors.textPlaceholder)),
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 18),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Semua Jenis'),
                            ),
                            ...jenisList.map((jenis) => DropdownMenuItem<String>(
                              value: jenis.id,
                              child: Text(
                                jenis.displayName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                          ],
                          onChanged: (value) {
                            ref.read(buahRawParamsProvider.notifier).setJenisDurianId(value);
                          },
                        ),
                      ),
                      loading: () => const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                      error: (_, __) => const Text('Err', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Sort Status Filter
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.fieldBackground),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<bool?>(
                        value: params.isSorted,
                        hint: const Text('Status', style: TextStyle(color: AppColors.textPlaceholder)),
                        isExpanded: true,
                        icon: const Icon(LucideIcons.chevronDown, size: 18),
                        items: const [
                          DropdownMenuItem<bool?>(
                            value: null,
                            child: Text('Semua'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('Unsorted'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: true,
                            child: Text('Sorted'),
                          ),
                        ],
                        onChanged: (value) {
                          ref.read(buahRawParamsProvider.notifier).setIsSorted(value);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Table Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.fieldBackground, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: buahAsync.when(
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
                          onPressed: () => ref.refresh(buahRawProvider),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                  data: (response) => _buildDataTable(response),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pagination Controls
            if (buahAsync.hasValue)
              _buildPagination(buahAsync.value!.meta, params.page),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(UnsortedBuahResponse response) {
    if (response.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.inbox, color: AppColors.textPlaceholder, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada data buah',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.fieldBackground.withOpacity(0.5)),
          dataRowMinHeight: 48,
          dataRowMaxHeight: 60,
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Kode Buah', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Jenis', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Lokasi', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Pohon', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Tgl Panen', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(response.data.length, (index) {
            final item = response.data[index];
            final params = ref.read(buahRawParamsProvider);
            final rowNum = ((params.page - 1) * params.limit) + index + 1;
            return DataRow(
              cells: [
                DataCell(Text('$rowNum')),
                DataCell(
                  Container(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      item.kodeBuah,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.blueDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.jenisDurian.displayName,
                      style: const TextStyle(
                        color: AppColors.blueDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      item.lokasiPanen.kodeLengkap,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(item.pohonPanen)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isSorted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.isSorted ? 'Sorted' : 'Unsorted',
                      style: TextStyle(
                        color: item.isSorted ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(_formatDate(item.tglPanen))),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPagination(PaginationMeta meta, int currentPage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.fieldBackground),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info
          Text(
            'Halaman $currentPage dari ${meta.totalPage} (${meta.totalData} data)',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          
          // Pagination Buttons
          Row(
            children: [
              // Previous Button
              IconButton(
                onPressed: currentPage > 1 ? () => _goToPage(currentPage - 1) : null,
                icon: const Icon(LucideIcons.chevronLeft),
                color: currentPage > 1 ? AppColors.black : AppColors.textPlaceholder,
              ),
              
              // Page Numbers
              ...List.generate(
                _getVisiblePages(currentPage, meta.totalPage).length,
                (index) {
                  final page = _getVisiblePages(currentPage, meta.totalPage)[index];
                  if (page == -1) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('...', style: TextStyle(color: AppColors.textSecondary)),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: page != currentPage ? () => _goToPage(page) : null,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: page == currentPage ? AppColors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$page',
                          style: TextStyle(
                            color: page == currentPage ? AppColors.white : AppColors.textPrimary,
                            fontWeight: page == currentPage ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Next Button
              IconButton(
                onPressed: currentPage < meta.totalPage ? () => _goToPage(currentPage + 1) : null,
                icon: const Icon(LucideIcons.chevronRight),
                color: currentPage < meta.totalPage ? AppColors.black : AppColors.textPlaceholder,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<int> _getVisiblePages(int currentPage, int totalPage) {
    if (totalPage <= 5) {
      return List.generate(totalPage, (i) => i + 1);
    }
    
    List<int> pages = [];
    if (currentPage <= 3) {
      pages = [1, 2, 3, 4, -1, totalPage];
    } else if (currentPage >= totalPage - 2) {
      pages = [1, -1, totalPage - 3, totalPage - 2, totalPage - 1, totalPage];
    } else {
      pages = [1, -1, currentPage - 1, currentPage, currentPage + 1, -1, totalPage];
    }
    return pages;
  }
}
