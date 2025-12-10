import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/sales/data/datasources/sales_remote_data_source.dart';
import 'package:wms_durich/features/sales/data/models/sales_models.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepositoryImpl(ref.read(salesRemoteDataSourceProvider));
});

abstract class SalesRepository {
  Future<List<SalesModel>> getSales({String? startDate, String? endDate, String? tipeJual});
  Future<SalesModel> getSalesDetail(String id);
  Future<SalesModel> createSales(CreateSalesRequest request);
  Future<void> updateSales(String id, UpdateSalesRequest request);
  Future<void> voidSales(String id);
}

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource _dataSource;

  SalesRepositoryImpl(this._dataSource);

  @override
  Future<List<SalesModel>> getSales({String? startDate, String? endDate, String? tipeJual}) {
    return _dataSource.getSales(startDate: startDate, endDate: endDate, tipeJual: tipeJual);
  }

  @override
  Future<SalesModel> getSalesDetail(String id) {
    return _dataSource.getSalesDetail(id);
  }

  @override
  Future<SalesModel> createSales(CreateSalesRequest request) {
    return _dataSource.createSales(request);
  }

  @override
  Future<void> updateSales(String id, UpdateSalesRequest request) {
    return _dataSource.updateSales(id, request);
  }

  @override
  Future<void> voidSales(String id) {
    return _dataSource.voidSales(id);
  }
}
