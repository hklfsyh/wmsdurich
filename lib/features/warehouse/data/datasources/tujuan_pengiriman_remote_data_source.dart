import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/core/network/dio_provider.dart';
import 'package:wms_durich/features/warehouse/data/models/tujuan_pengiriman_model.dart';

final tujuanPengirimanRemoteDataSourceProvider =
    Provider<TujuanPengirimanRemoteDataSource>((ref) {
  return TujuanPengirimanRemoteDataSourceImpl(ref.read(dioProvider));
});

abstract class TujuanPengirimanRemoteDataSource {
  Future<List<TujuanPengirimanModel>> getTujuanPengirimanList({String? tipe});
  Future<TujuanPengirimanModel> getTujuanPengirimanById(String id);
  Future<TujuanPengirimanModel> createTujuanPengiriman(
      CreateTujuanPengirimanRequest request);
  Future<TujuanPengirimanModel> updateTujuanPengiriman(
      String id, UpdateTujuanPengirimanRequest request);
  Future<void> deleteTujuanPengiriman(String id);
}

class TujuanPengirimanRemoteDataSourceImpl
    implements TujuanPengirimanRemoteDataSource {
  final Dio _dio;

  TujuanPengirimanRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TujuanPengirimanModel>> getTujuanPengirimanList({String? tipe}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (tipe != null && tipe.isNotEmpty) {
        queryParams['tipe'] = tipe;
      }
      
      final response = await _dio.get('/v1/tujuan-pengiriman', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final responseData = TujuanPengirimanListResponse.fromJson(response.data);
        return responseData.data;
      } else {
        throw Exception(
            'Failed to load tujuan pengiriman: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tujuan pengiriman: $e');
    }
  }

  @override
  Future<TujuanPengirimanModel> getTujuanPengirimanById(String id) async {
    try {
      final response = await _dio.get('/v1/tujuan-pengiriman/$id');

      if (response.statusCode == 200) {
        final responseData = TujuanPengirimanResponse.fromJson(response.data);
        return responseData.data;
      } else {
        throw Exception(
            'Failed to load tujuan pengiriman: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tujuan pengiriman: $e');
    }
  }

  @override
  Future<TujuanPengirimanModel> createTujuanPengiriman(
      CreateTujuanPengirimanRequest request) async {
    try {
      final response = await _dio.post(
        '/v1/tujuan-pengiriman',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        final responseData = TujuanPengirimanResponse.fromJson(response.data);
        return responseData.data;
      } else {
        throw Exception(
            'Failed to create tujuan pengiriman: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating tujuan pengiriman: $e');
    }
  }

  @override
  Future<TujuanPengirimanModel> updateTujuanPengiriman(
      String id, UpdateTujuanPengirimanRequest request) async {
    try {
      final response = await _dio.put(
        '/v1/tujuan-pengiriman/$id',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final responseData = TujuanPengirimanResponse.fromJson(response.data);
        return responseData.data;
      } else {
        throw Exception(
            'Failed to update tujuan pengiriman: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating tujuan pengiriman: $e');
    }
  }

  @override
  Future<void> deleteTujuanPengiriman(String id) async {
    try {
      final response = await _dio.delete('/v1/tujuan-pengiriman/$id');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete tujuan pengiriman: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting tujuan pengiriman: $e');
    }
  }
}
