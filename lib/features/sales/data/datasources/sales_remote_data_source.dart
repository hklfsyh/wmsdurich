import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/core/network/dio_provider.dart';
import 'package:wms_durich/features/sales/data/models/sales_models.dart';

final salesRemoteDataSourceProvider = Provider<SalesRemoteDataSource>((ref) {
  return SalesRemoteDataSourceImpl(ref.read(dioProvider));
});

abstract class SalesRemoteDataSource {
  Future<List<SalesModel>> getSales({String? startDate, String? endDate, String? tipeJual});
  Future<SalesModel> getSalesDetail(String id);
  Future<SalesModel> createSales(CreateSalesRequest request);
  Future<void> updateSales(String id, UpdateSalesRequest request);
  Future<void> voidSales(String id);
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final Dio _dio;

  SalesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<SalesModel>> getSales({String? startDate, String? endDate, String? tipeJual}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (tipeJual != null && tipeJual != 'all') queryParams['tipe_jual'] = tipeJual;

      final response = await _dio.get('/v1/sales', queryParameters: queryParams);
      
      final data = response.data['data'];
      if (data == null) {
        return [];
      }

      final listData = data as List;
      return listData.map((e) => SalesModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SalesModel> getSalesDetail(String id) async {
    try {
      final response = await _dio.get('/v1/sales/$id');
      return SalesModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SalesModel> createSales(CreateSalesRequest request) async {
    try {
      final response = await _dio.post('/v1/sales', data: request.toJson());
      return SalesModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateSales(String id, UpdateSalesRequest request) async {
    try {
      await _dio.put('/v1/sales/$id', data: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> voidSales(String id) async {
    try {
      await _dio.delete('/v1/sales/$id');
    } catch (e) {
      rethrow;
    }
  }
}
