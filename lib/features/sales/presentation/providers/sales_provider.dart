import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/sales/data/models/sales_models.dart';
import 'package:wms_durich/features/sales/data/repositories/sales_repository.dart';

class SalesState {
  final List<SalesModel> sales;
  final bool isLoading;
  final String? error;

  SalesState({
    required this.sales,
    this.isLoading = false,
    this.error,
  });

  SalesState copyWith({
    List<SalesModel>? sales,
    bool? isLoading,
    String? error,
  }) {
    return SalesState(
      sales: sales ?? this.sales,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SalesNotifier extends Notifier<SalesState> {
  late final SalesRepository _repository;

  @override
  SalesState build() {
    _repository = ref.read(salesRepositoryProvider);
    return SalesState(sales: []);
  }

  Future<void> loadSales({String? tipeJual}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sales = await _repository.getSales(tipeJual: tipeJual);
      state = state.copyWith(sales: sales, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createSales({
    required String pengirimanId,
    required double beratTerjual,
    required double hargaTotal,
    required String tipeJual,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final request = CreateSalesRequest(
        pengirimanId: pengirimanId,
        beratTerjual: beratTerjual,
        hargaTotal: hargaTotal,
        tipeJual: tipeJual,
      );
      await _repository.createSales(request);
      await loadSales(); // Refresh list
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateSales({
    required String id,
    required double beratTerjual,
    required double hargaTotal,
    required String tipeJual,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final request = UpdateSalesRequest(
        beratTerjual: beratTerjual,
        hargaTotal: hargaTotal,
        tipeJual: tipeJual,
      );
      await _repository.updateSales(id, request);
      await loadSales();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> voidSales(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.voidSales(id);
      await loadSales();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final salesProvider = NotifierProvider<SalesNotifier, SalesState>(SalesNotifier.new);
