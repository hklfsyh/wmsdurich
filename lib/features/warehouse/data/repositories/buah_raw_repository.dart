import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/datasources/buah_raw_remote_data_source.dart';
import 'package:wms_durich/features/warehouse/data/models/buah_raw_models.dart';

final buahRawRepositoryProvider = Provider<BuahRawRepository>((ref) {
  return BuahRawRepositoryImpl(ref.read(buahRawRemoteDataSourceProvider));
});

abstract class BuahRawRepository {
  Future<BuahRawBulkResponse> createBulkBuahRaw(BuahRawBulkRequest request);
  Future<UnsortedBuahResponse> getUnsortedBuahRaw({
    int page = 1,
    int limit = 50,
    String? kodeBuah,
    String? jenisDurianId,
  });
}

class BuahRawRepositoryImpl implements BuahRawRepository {
  final BuahRawRemoteDataSource _dataSource;

  BuahRawRepositoryImpl(this._dataSource);

  @override
  Future<BuahRawBulkResponse> createBulkBuahRaw(BuahRawBulkRequest request) async {
    return await _dataSource.createBulkBuahRaw(request);
  }

  @override
  Future<UnsortedBuahResponse> getUnsortedBuahRaw({
    int page = 1,
    int limit = 50,
    String? kodeBuah,
    String? jenisDurianId,
  }) async {
    return await _dataSource.getUnsortedBuahRaw(
      page: page,
      limit: limit,
      kodeBuah: kodeBuah,
      jenisDurianId: jenisDurianId,
    );
  }
}
