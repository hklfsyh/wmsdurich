import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/datasources/master_data_remote_data_source.dart';
import 'package:wms_durich/features/warehouse/data/models/master_data_models.dart';

final masterDataRepositoryProvider = Provider<MasterDataRepository>((ref) {
  return MasterDataRepositoryImpl(ref.read(masterDataRemoteDataSourceProvider));
});

abstract class MasterDataRepository {
  Future<List<BlokModel>> getBloks();
  Future<List<JenisDurianModel>> getJenisDurian();
  Future<List<PohonModel>> getPohon();
  Future<WarehouseDataModel> getWarehouseData();
}

class MasterDataRepositoryImpl implements MasterDataRepository {
  final MasterDataRemoteDataSource _dataSource;

  MasterDataRepositoryImpl(this._dataSource);

  @override
  Future<List<BlokModel>> getBloks() async {
    return await _dataSource.getBloks();
  }

  @override
  Future<List<JenisDurianModel>> getJenisDurian() async {
    return await _dataSource.getJenisDurian();
  }

  @override
  Future<List<PohonModel>> getPohon() async {
    return await _dataSource.getPohon();
  }

  @override
  Future<WarehouseDataModel> getWarehouseData() async {
    return await _dataSource.getWarehouseData();
  }
}
