import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/core/network/dio_provider.dart';
import 'package:wms_durich/features/warehouse/data/models/master_data_models.dart';

// USING REAL API
final masterDataRemoteDataSourceProvider =
    Provider<MasterDataRemoteDataSource>((ref) {
  return MasterDataRemoteDataSourceImpl(ref.read(dioProvider));
});

abstract class MasterDataRemoteDataSource {
  Future<List<BlokModel>> getBloks();
  Future<List<JenisDurianModel>> getJenisDurian();
  Future<List<PohonModel>> getPohon();
  Future<WarehouseDataModel> getWarehouseData();
}

class MasterDataRemoteDataSourceImpl implements MasterDataRemoteDataSource {
  final Dio _dio;

  MasterDataRemoteDataSourceImpl(this._dio);

  @override
  Future<List<BlokModel>> getBloks() async {
    try {
      final response = await _dio.get('/v1/bloks');
      final data = response.data['data'] as List;
      return data.map((e) => BlokModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch bloks: $e');
    }
  }

  @override
  Future<List<JenisDurianModel>> getJenisDurian() async {
    try {
      final response = await _dio.get('/v1/jenis-durian');
      final data = response.data['data'] as List;
      return data.map((e) => JenisDurianModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch jenis durian: $e');
    }
  }

  @override
  Future<List<PohonModel>> getPohon() async {
    try {
      final response = await _dio.get('/v1/pohon');
      final data = response.data['data'] as List;
      return data.map((e) => PohonModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch pohon: $e');
    }
  }

  @override
  Future<WarehouseDataModel> getWarehouseData() async {
    try {
      final response = await _dio.get('/v1/dashboard/warehouse-data');
      final data = response.data['data'];
      return WarehouseDataModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch warehouse data: $e');
    }
  }
}
