import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/core/network/dio_provider.dart';
import 'package:wms_durich/features/warehouse/data/models/shipment_models.dart';
import 'package:wms_durich/features/warehouse/data/models/shipment_requests.dart';
import 'package:wms_durich/features/warehouse/data/models/receive_shipment_request.dart';

final shipmentRemoteDataSourceProvider = Provider<ShipmentRemoteDataSource>((ref) {
  return ShipmentRemoteDataSourceImpl(ref.read(dioProvider));
});

abstract class ShipmentRemoteDataSource {
  Future<List<ShipmentModel>> getShipments({String? status, String? type});
  Future<ShipmentDetailResponse> getShipmentDetail(String id);
  Future<ShipmentModel> createShipment(CreateShipmentRequest request);
  Future<void> addItemToShipment(String id, AddItemToShipmentRequest request);
  Future<void> removeItemFromShipment(String id, String detailId);
  Future<void> finalizeShipment(String id);
  Future<void> updateShipmentStatus(String id, String status, {String? notes});
  Future<void> receiveShipment(String id, ReceiveShipmentRequest request);
}

class ShipmentRemoteDataSourceImpl implements ShipmentRemoteDataSource {
  final Dio _dio;

  ShipmentRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ShipmentModel>> getShipments({String? status, String? type}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      
      final response = await _dio.get('/v1/shipments', queryParameters: queryParams);
      final data = response.data['data']['data'] as List;
      return data.map((e) => ShipmentModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ShipmentDetailResponse> getShipmentDetail(String id) async {
    try {
      final response = await _dio.get('/v1/shipments/$id');
      return ShipmentDetailResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ShipmentModel> createShipment(CreateShipmentRequest request) async {
    try {
      final response = await _dio.post('/v1/shipments', data: request.toJson());
      // Handle case where data might be nested or direct
      final responseData = response.data;
      final data = responseData is Map<String, dynamic> && responseData.containsKey('data') 
          ? responseData['data'] 
          : responseData;
          
      if (data == null) {
        throw Exception('API returned null data');
      }
      
      return ShipmentModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addItemToShipment(String id, AddItemToShipmentRequest request) async {
    try {
      await _dio.post('/v1/shipments/$id/items', data: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeItemFromShipment(String id, String detailId) async {
    try {
      // Body request for delete
      await _dio.delete(
        '/v1/shipments/$id/items', 
        data: {'detail_id': detailId}
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> finalizeShipment(String id) async {
    try {
      await _dio.post('/v1/shipments/$id/finalize');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateShipmentStatus(String id, String status, {String? notes}) async {
    try {
      final data = {
        'status': status,
        if (notes != null) 'notes': notes,
      };
      await _dio.put('/v1/shipments/$id/status', data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> receiveShipment(String id, ReceiveShipmentRequest request) async {
    try {
      await _dio.post('/v1/shipments/$id/receive', data: request.toJson());
    } catch (e) {
      rethrow;
    }
  }
}
