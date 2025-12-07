import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/datasources/shipment_remote_data_source.dart';
import 'package:wms_durich/features/warehouse/data/models/shipment_models.dart';
import 'package:wms_durich/features/warehouse/data/models/shipment_requests.dart';

final shipmentRepositoryProvider = Provider<ShipmentRepository>((ref) {
  return ShipmentRepositoryImpl(ref.read(shipmentRemoteDataSourceProvider));
});

abstract class ShipmentRepository {
  Future<List<ShipmentModel>> getShipments({String? status});
  Future<ShipmentDetailResponse> getShipmentDetail(String id);
  Future<ShipmentModel> createShipment(String tujuan, DateTime tglKirim);
  Future<void> addItemToShipment(String id, String lotId, int qty, double berat);
  Future<void> removeItemFromShipment(String id, String detailId);
  Future<void> finalizeShipment(String id);
  Future<void> cancelShipment(String id);
}

class ShipmentRepositoryImpl implements ShipmentRepository {
  final ShipmentRemoteDataSource _dataSource;

  ShipmentRepositoryImpl(this._dataSource);

  @override
  Future<List<ShipmentModel>> getShipments({String? status}) {
    return _dataSource.getShipments(status: status);
  }

  @override
  Future<ShipmentDetailResponse> getShipmentDetail(String id) {
    return _dataSource.getShipmentDetail(id);
  }

  @override
  Future<ShipmentModel> createShipment(String tujuan, DateTime tglKirim) {
    // Format datetime with Z suffix for Go backend compatibility
    final utcTime = tglKirim.toUtc();
    final formattedDate = '${utcTime.toIso8601String().split('.')[0]}Z';
    
    final request = CreateShipmentRequest(
      tujuan: tujuan,
      tglKirim: formattedDate,
    );
    return _dataSource.createShipment(request);
  }

  @override
  Future<void> addItemToShipment(String id, String lotId, int qty, double berat) {
    final request = AddItemToShipmentRequest(
      lotId: lotId,
      qty: qty,
      berat: berat,
    );
    return _dataSource.addItemToShipment(id, request);
  }

  @override
  Future<void> removeItemFromShipment(String id, String detailId) {
    return _dataSource.removeItemFromShipment(id, detailId);
  }

  @override
  Future<void> finalizeShipment(String id) {
    return _dataSource.finalizeShipment(id);
  }

  @override
  Future<void> cancelShipment(String id) {
    return _dataSource.updateShipmentStatus(id, 'CANCELLED');
  }
}
