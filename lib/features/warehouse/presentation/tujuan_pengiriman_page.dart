import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/auth/presentation/providers/auth_provider.dart';
import 'package:wms_durich/features/warehouse/data/models/tujuan_pengiriman_model.dart';
import 'package:wms_durich/features/warehouse/presentation/providers/tujuan_pengiriman_provider.dart';

class TujuanPengirimanPage extends ConsumerStatefulWidget {
  const TujuanPengirimanPage({super.key});

  @override
  ConsumerState<TujuanPengirimanPage> createState() =>
      _TujuanPengirimanPageState();
}

class _TujuanPengirimanPageState extends ConsumerState<TujuanPengirimanPage> {
  String? _selectedTipe;

  Future<void> _refreshData() async {
    await ref.read(tujuanPengirimanProvider.notifier).refreshTujuanPengiriman(tipe: _selectedTipe);
  }

  void _onFilterChanged(String? newValue) {
    setState(() {
      _selectedTipe = newValue;
    });
    ref.read(tujuanPengirimanProvider.notifier).loadTujuanPengiriman(tipe: newValue);
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => const TujuanPengirimanFormDialog(),
    );
  }

  void _showEditDialog(TujuanPengirimanModel tujuan) {
    showDialog(
      context: context,
      builder: (context) => TujuanPengirimanFormDialog(tujuan: tujuan),
    );
  }

  Future<void> _confirmDelete(TujuanPengirimanModel tujuan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tujuan Pengiriman'),
        content: Text('Yakin ingin menghapus "${tujuan.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(tujuanPengirimanProvider.notifier)
            .deleteTujuanPengiriman(tujuan.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tujuan pengiriman berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tujuanPengirimanProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    // Tombol CRUD hanya untuk Admin Pusat
    final isCentralAdmin = user?.isCentralAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tujuan Pengiriman'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Filter Button
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.filter),
            tooltip: 'Filter Tipe',
            onSelected: _onFilterChanged,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: null,
                  child: Text('Semua Tipe'),
                ),
                const PopupMenuItem<String>(
                  value: 'internal',
                  child: Text('Internal'),
                ),
                const PopupMenuItem<String>(
                  value: 'external',
                  child: Text('External'),
                ),
              ];
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: state.isLoading && state.tujuanList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.error != null && state.tujuanList.isEmpty
                ? _buildErrorState(state.error!)
                : state.tujuanList.isEmpty
                    ? _buildEmptyState()
                    : _buildList(state.tujuanList, isCentralAdmin),
      ),
      floatingActionButton: isCentralAdmin ? FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text(
          'Tambah Tujuan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ) : null,
    );
  }

  Widget _buildList(List<TujuanPengirimanModel> tujuanList, bool isEditable) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tujuanList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tujuan = tujuanList[index];
        return _buildTujuanCard(tujuan, isEditable);
      },
    );
  }

  Widget _buildTujuanCard(TujuanPengirimanModel tujuan, bool isEditable) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isEditable ? () => _showEditDialog(tujuan) : null,
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
                      color: tujuan.tipe == 'internal'
                          ? Colors.blue.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      tujuan.tipe == 'internal'
                          ? LucideIcons.warehouse
                          : LucideIcons.store,
                      color: tujuan.tipe == 'internal'
                          ? Colors.blue.shade700
                          : Colors.green.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tujuan.nama,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: tujuan.tipe == 'internal'
                                ? Colors.blue.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tujuan.tipe == 'internal' ? 'Internal' : 'External',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: tujuan.tipe == 'internal'
                                  ? Colors.blue.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEditable)
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, size: 20),
                      color: Colors.red.shade400,
                      onPressed: () => _confirmDelete(tujuan),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(LucideIcons.mapPin,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tujuan.alamat,
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
                children: [
                  const Icon(LucideIcons.phone,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    tujuan.kontak,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.mapPin, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Belum ada tujuan pengiriman',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk menambah tujuan',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.alertCircle, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(LucideIcons.refreshCw),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class TujuanPengirimanFormDialog extends ConsumerStatefulWidget {
  final TujuanPengirimanModel? tujuan;

  const TujuanPengirimanFormDialog({super.key, this.tujuan});

  @override
  ConsumerState<TujuanPengirimanFormDialog> createState() =>
      _TujuanPengirimanFormDialogState();
}

class _TujuanPengirimanFormDialogState
    extends ConsumerState<TujuanPengirimanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _kontakController;
  String _tipe = 'external';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.tujuan?.nama ?? '');
    _alamatController =
        TextEditingController(text: widget.tujuan?.alamat ?? '');
    _kontakController =
        TextEditingController(text: widget.tujuan?.kontak ?? '');
    _tipe = widget.tujuan?.tipe ?? 'external';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _kontakController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.tujuan != null) {
        await ref.read(tujuanPengirimanProvider.notifier).updateTujuanPengiriman(
              id: widget.tujuan!.id,
              nama: _namaController.text.trim(),
              tipe: _tipe,
              alamat: _alamatController.text.trim(),
              kontak: _kontakController.text.trim(),
            );
      } else {
        await ref.read(tujuanPengirimanProvider.notifier).createTujuanPengiriman(
              nama: _namaController.text.trim(),
              tipe: _tipe,
              alamat: _alamatController.text.trim(),
              kontak: _kontakController.text.trim(),
            );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.tujuan != null
                  ? 'Tujuan pengiriman berhasil diupdate'
                  : 'Tujuan pengiriman berhasil ditambahkan',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
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
                    Expanded(
                      child: Text(
                        widget.tujuan != null
                            ? 'Edit Tujuan Pengiriman'
                            : 'Tambah Tujuan Pengiriman',
                        style: const TextStyle(
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
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Tujuan',
                    hintText: 'Contoh: Toko Buah Segar',
                    prefixIcon: const Icon(LucideIcons.store),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _tipe,
                  decoration: InputDecoration(
                    labelText: 'Tipe',
                    prefixIcon: const Icon(LucideIcons.tags),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'internal',
                      child: Text('Internal (Gudang)'),
                    ),
                    DropdownMenuItem(
                      value: 'external',
                      child: Text('External (Toko/Pelanggan)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tipe = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alamatController,
                  decoration: InputDecoration(
                    labelText: 'Alamat',
                    hintText: 'Jl. Raya Bogor No. 123',
                    prefixIcon: const Icon(LucideIcons.mapPin),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alamat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _kontakController,
                  decoration: InputDecoration(
                    labelText: 'Kontak',
                    hintText: '081234567890',
                    prefixIcon: const Icon(LucideIcons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kontak tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                      : Text(
                          widget.tujuan != null ? 'Update' : 'Tambah',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
