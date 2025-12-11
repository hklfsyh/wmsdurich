import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/models/tujuan_pengiriman_model.dart';
import 'package:wms_durich/features/warehouse/data/repositories/tujuan_pengiriman_repository.dart';

class TujuanPengirimanState {
  final List<TujuanPengirimanModel> tujuanList;
  final bool isLoading;
  final String? error;

  TujuanPengirimanState({
    this.tujuanList = const [],
    this.isLoading = false,
    this.error,
  });

  TujuanPengirimanState copyWith({
    List<TujuanPengirimanModel>? tujuanList,
    bool? isLoading,
    String? error,
  }) {
    return TujuanPengirimanState(
      tujuanList: tujuanList ?? this.tujuanList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final tujuanPengirimanProvider =
    StateNotifierProvider<TujuanPengirimanNotifier, TujuanPengirimanState>(
        (ref) {
  return TujuanPengirimanNotifier(
    ref.read(tujuanPengirimanRepositoryProvider),
  );
});

class TujuanPengirimanNotifier extends StateNotifier<TujuanPengirimanState> {
  final TujuanPengirimanRepository _repository;

  TujuanPengirimanNotifier(this._repository)
      : super(TujuanPengirimanState()) {
    // Don't load automatically on init if we want to filter by default or let UI decide
    loadTujuanPengiriman();
  }

  Future<void> loadTujuanPengiriman({String? tipe}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tujuanList = await _repository.getTujuanPengirimanList(tipe: tipe);
      state = state.copyWith(
        tujuanList: tujuanList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshTujuanPengiriman({String? tipe}) async {
    await loadTujuanPengiriman(tipe: tipe);
  }

  Future<TujuanPengirimanModel> createTujuanPengiriman({
    required String nama,
    required String tipe,
    required String alamat,
    required String kontak,
  }) async {
    try {
      final newTujuan = await _repository.createTujuanPengiriman(
        nama,
        tipe,
        alamat,
        kontak,
      );
      await loadTujuanPengiriman();
      return newTujuan;
    } catch (e) {
      throw Exception('Gagal membuat tujuan pengiriman: $e');
    }
  }

  Future<void> updateTujuanPengiriman({
    required String id,
    required String nama,
    required String tipe,
    required String alamat,
    required String kontak,
  }) async {
    try {
      await _repository.updateTujuanPengiriman(id, nama, tipe, alamat, kontak);
      await loadTujuanPengiriman();
    } catch (e) {
      throw Exception('Gagal mengupdate tujuan pengiriman: $e');
    }
  }

  Future<void> deleteTujuanPengiriman(String id) async {
    try {
      await _repository.deleteTujuanPengiriman(id);
      await loadTujuanPengiriman();
    } catch (e) {
      throw Exception('Gagal menghapus tujuan pengiriman: $e');
    }
  }
}
