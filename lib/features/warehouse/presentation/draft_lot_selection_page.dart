import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/warehouse/data/models/lot_models.dart';
import 'package:wms_durich/features/warehouse/presentation/add_lot_stock_page_new.dart';
import 'package:wms_durich/features/warehouse/presentation/add_lot_stock_proses_page.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/lot_provider.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/master_data_provider.dart';

class DraftLotSelectionPage extends ConsumerStatefulWidget {
  const DraftLotSelectionPage({super.key});

  @override
  ConsumerState<DraftLotSelectionPage> createState() => _DraftLotSelectionPageState();
}

class _DraftLotSelectionPageState extends ConsumerState<DraftLotSelectionPage> {
  String? _selectedJenisDurianId;

  @override
  void initState() {
    super.initState();
    // Invalidate provider to fetch fresh data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(allDraftLotsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter locally since allDraftLotsProvider fetches all drafts
    // Alternatively, update provider to accept filters if backend supports it for drafts
    // Assuming backend supports filtering drafts via same endpoint?
    // Let's filter locally for now as the provider logic for 'allDraftLotsProvider' is simple.
    // Actually, 'allDraftLotsProvider' uses 'getLots(status: DRAFT)'. 
    // If we want to filter by jenis_durian_id, we should update the provider or pass parameters.
    // But 'allDraftLotsProvider' is a FutureProvider.
    // Let's filter client-side for simplicity if the list is not huge, or update provider call.
    // Since we can't easily change the FutureProvider params dynamically without family,
    // let's do client-side filtering on the returned list.
    
    final draftLotsAsync = ref.watch(allDraftLotsProvider);
    final jenisDurianAsync = ref.watch(jenisDurianProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat / Lanjutkan Lot'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Option 1: Create New Lot
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddLotStockProsesPage(),
                  ),
                );
                
                if (result == true) {
                  // If lot finalized/created, refresh list
                  ref.invalidate(allDraftLotsProvider);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.plusCircle, color: Colors.white, size: 32),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buat Lot Baru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mulai proses lotting dari awal',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(LucideIcons.chevronRight, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 32),
          ),

          // Option 2: Continue Draft
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.history, size: 20, color: AppColors.textPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Lanjutkan Lot Draft',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // Filter Dropdown
                SizedBox(
                  width: 150,
                  height: 40,
                  child: jenisDurianAsync.when(
                    data: (jenisList) => DropdownButtonFormField<String>(
                      value: _selectedJenisDurianId,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Filter Jenis',
                        hintStyle: const TextStyle(fontSize: 12),
                      ),
                      isExpanded: true,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      icon: const Icon(LucideIcons.filter, size: 16),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Semua Jenis'),
                        ),
                        ...jenisList.map((jenis) => DropdownMenuItem<String>(
                          value: jenis.id,
                          child: Text(jenis.namaJenis, overflow: TextOverflow.ellipsis),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedJenisDurianId = value;
                        });
                      },
                    ),
                    loading: () => const SizedBox(),
                    error: (_,__) => const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: draftLotsAsync.when(
              data: (response) {
                // Apply local filter
                final filteredList = _selectedJenisDurianId == null 
                    ? response.data 
                    : response.data.where((lot) => lot.jenisDurianId == _selectedJenisDurianId).toList();

                if (filteredList.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allDraftLotsProvider);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lot = filteredList[index];
                      return _buildDraftLotCard(context, lot);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.fileClock, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Tidak ada Lot Draft',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat lot baru untuk memulai',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftLotCard(BuildContext context, LotModel lot) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          // Navigate to Process Page passing the lot ID to resume
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLotStockProsesPage(resumeLotId: lot.id, resumeLotKode: lot.kode),
            ),
          );

          if (result == true) {
            // If lot finalized, refresh list
            ref.invalidate(allDraftLotsProvider);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.package, color: Colors.orange.shade700),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.kode,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lot.jenisDurianNama} • ${lot.kondisiBuah}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lot.currentQty} item • ${lot.currentBerat} kg',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
