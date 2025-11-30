import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/core/network/dio_provider.dart';
import 'package:wms_durich/features/warehouse/data/models/lot_models.dart';

final lotRemoteDataSourceProvider = Provider<LotRemoteDataSource>((ref) {
  return LotRemoteDataSourceImpl(ref.read(dioProvider));
});

abstract class LotRemoteDataSource {
  Future<LotsResponse> getLots({String? status, String? jenisDurianId, String? kondisi});
  Future<LotDetailResponse> getLotDetail(String lotId);
  Future<CreateLotResponse> createLot(CreateLotRequest request);
  Future<AddItemsToLotResponse> addItemsToLot(String lotId, AddItemsToLotRequest request);
  Future<FinalizeLotResponse> finalizeLot(String lotId, FinalizeLotRequest request);
}

class LotRemoteDataSourceImpl implements LotRemoteDataSource {
  final Dio _dio;

  LotRemoteDataSourceImpl(this._dio);

  @override
  Future<LotsResponse> getLots({String? status, String? jenisDurianId, String? kondisi}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (jenisDurianId != null && jenisDurianId.isNotEmpty) {
        queryParams['jenis_durian_id'] = jenisDurianId;
      }
      if (kondisi != null && kondisi.isNotEmpty) {
        queryParams['kondisi'] = kondisi;
      }
      final response = await _dio.get('/v1/lots', queryParameters: queryParams);
      return LotsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LotDetailResponse> getLotDetail(String lotId) async {
    try {
      final response = await _dio.get('/v1/lots/$lotId');
      return LotDetailResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CreateLotResponse> createLot(CreateLotRequest request) async {
    try {
      final response = await _dio.post('/v1/lots', data: request.toJson());
      return CreateLotResponse.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AddItemsToLotResponse> addItemsToLot(String lotId, AddItemsToLotRequest request) async {
    try {
      final response = await _dio.post('/v1/lots/$lotId/items', data: request.toJson());
      return AddItemsToLotResponse.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FinalizeLotResponse> finalizeLot(String lotId, FinalizeLotRequest request) async {
    try {
      final response = await _dio.post('/v1/lots/$lotId/finalize', data: request.toJson());
      return FinalizeLotResponse.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }
}
