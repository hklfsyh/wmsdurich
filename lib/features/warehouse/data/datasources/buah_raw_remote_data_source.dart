import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/models/buah_raw_models.dart';
import 'package:wms_durich/features/warehouse/data/datasources/buah_raw_mock_data_source.dart';

// USING MOCK DATA - API is down
final buahRawRemoteDataSourceProvider =
    Provider<BuahRawRemoteDataSource>((ref) {
  return BuahRawMockDataSourceImpl();
  // return BuahRawRemoteDataSourceImpl(ref.read(dioProvider)); // Original API call
});

abstract class BuahRawRemoteDataSource {
  Future<BuahRawBulkResponse> createBulkBuahRaw(BuahRawBulkRequest request);
  Future<UnsortedBuahResponse> getUnsortedBuahRaw({
    int page = 1,
    int limit = 50,
    String? kodeBuah,
    String? jenisDurianId,
  });

  Future<UnsortedBuahResponse> getBuahRaw({
    int page = 1,
    int limit = 50,
    String? kodeBuah,
    String? jenisDurianId,
    String? tglPanen,
    bool? isSorted,
  });
}

class BuahRawRemoteDataSourceImpl implements BuahRawRemoteDataSource {
  final Dio _dio;

  BuahRawRemoteDataSourceImpl(this._dio);

  @override
  Future<BuahRawBulkResponse> createBulkBuahRaw(
      BuahRawBulkRequest request) async {
    try {
      final response = await _dio.post(
        '/v1/buah-raw/bulk',
        data: request.toJson(),
      );
      return BuahRawBulkResponse.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UnsortedBuahResponse> getUnsortedBuahRaw({
    int page = 1,
    int limit = 50,
    String? kodeBuah,
    String? jenisDurianId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (kodeBuah != null && kodeBuah.isNotEmpty) {
        queryParams['kode_buah'] = kodeBuah;
      }
      if (jenisDurianId != null && jenisDurianId.isNotEmpty) {
        queryParams['jenis_durian_id'] = jenisDurianId;
      }
      final response = await _dio.get(
        '/v1/buah-raw/unsorted',
        queryParameters: queryParams,
      );
      return UnsortedBuahResponse.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UnsortedBuahResponse> getBuahRaw({
    int page = 1,
    int limit = 50,
    String? kodeBuah,
    String? jenisDurianId,
    String? tglPanen,
    bool? isSorted,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (kodeBuah != null && kodeBuah.isNotEmpty) {
        queryParams['kode_buah'] = kodeBuah;
      }
      if (jenisDurianId != null && jenisDurianId.isNotEmpty) {
        queryParams['jenis_durian_id'] = jenisDurianId;
      }
      if (tglPanen != null && tglPanen.isNotEmpty) {
        queryParams['tgl_panen'] = tglPanen;
      }
      if (isSorted != null) {
        queryParams['is_sorted'] = isSorted.toString();
      }

      final response = await _dio.get(
        '/v1/buah-raw',
        queryParameters: queryParams,
      );
      return UnsortedBuahResponse.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }
}
