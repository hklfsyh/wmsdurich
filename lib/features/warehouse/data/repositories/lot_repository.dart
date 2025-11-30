import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/datasources/lot_remote_data_source.dart';
import 'package:wms_durich/features/warehouse/data/models/lot_models.dart';

final lotRepositoryProvider = Provider<LotRepository>((ref) {
  return LotRepositoryImpl(ref.read(lotRemoteDataSourceProvider));
});

abstract class LotRepository {
  Future<LotsResponse> getLots({String? status, String? jenisDurianId, String? kondisi});
  Future<LotDetailResponse> getLotDetail(String lotId);
  Future<CreateLotResponse> createLot(CreateLotRequest request);
  Future<AddItemsToLotResponse> addItemsToLot(String lotId, AddItemsToLotRequest request);
  Future<FinalizeLotResponse> finalizeLot(String lotId, FinalizeLotRequest request);
}

class LotRepositoryImpl implements LotRepository {
  final LotRemoteDataSource _dataSource;

  LotRepositoryImpl(this._dataSource);

  @override
  Future<LotsResponse> getLots({String? status, String? jenisDurianId, String? kondisi}) async {
    return await _dataSource.getLots(status: status, jenisDurianId: jenisDurianId, kondisi: kondisi);
  }

  @override
  Future<LotDetailResponse> getLotDetail(String lotId) async {
    return await _dataSource.getLotDetail(lotId);
  }

  @override
  Future<CreateLotResponse> createLot(CreateLotRequest request) async {
    return await _dataSource.createLot(request);
  }

  @override
  Future<AddItemsToLotResponse> addItemsToLot(String lotId, AddItemsToLotRequest request) async {
    return await _dataSource.addItemsToLot(lotId, request);
  }

  @override
  Future<FinalizeLotResponse> finalizeLot(String lotId, FinalizeLotRequest request) async {
    return await _dataSource.finalizeLot(lotId, request);
  }
}
