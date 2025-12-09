import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/datasources/tujuan_pengiriman_remote_data_source.dart';
import 'package:wms_durich/features/warehouse/data/models/tujuan_pengiriman_model.dart';

final tujuanPengirimanRepositoryProvider =
    Provider<TujuanPengirimanRepository>((ref) {
  return TujuanPengirimanRepositoryImpl(
      ref.read(tujuanPengirimanRemoteDataSourceProvider));
});

abstract class TujuanPengirimanRepository {
  Future<List<TujuanPengirimanModel>> getTujuanPengirimanList();
  Future<TujuanPengirimanModel> getTujuanPengirimanById(String id);
  Future<TujuanPengirimanModel> createTujuanPengiriman(
      String nama, String tipe, String alamat, String kontak);
  Future<TujuanPengirimanModel> updateTujuanPengiriman(
      String id, String nama, String tipe, String alamat, String kontak);
  Future<void> deleteTujuanPengiriman(String id);
}

class TujuanPengirimanRepositoryImpl implements TujuanPengirimanRepository {
  final TujuanPengirimanRemoteDataSource _dataSource;

  TujuanPengirimanRepositoryImpl(this._dataSource);

  @override
  Future<List<TujuanPengirimanModel>> getTujuanPengirimanList() {
    return _dataSource.getTujuanPengirimanList();
  }

  @override
  Future<TujuanPengirimanModel> getTujuanPengirimanById(String id) {
    return _dataSource.getTujuanPengirimanById(id);
  }

  @override
  Future<TujuanPengirimanModel> createTujuanPengiriman(
      String nama, String tipe, String alamat, String kontak) {
    final request = CreateTujuanPengirimanRequest(
      nama: nama,
      tipe: tipe,
      alamat: alamat,
      kontak: kontak,
    );
    return _dataSource.createTujuanPengiriman(request);
  }

  @override
  Future<TujuanPengirimanModel> updateTujuanPengiriman(
      String id, String nama, String tipe, String alamat, String kontak) {
    final request = UpdateTujuanPengirimanRequest(
      nama: nama,
      tipe: tipe,
      alamat: alamat,
      kontak: kontak,
    );
    return _dataSource.updateTujuanPengiriman(id, request);
  }

  @override
  Future<void> deleteTujuanPengiriman(String id) {
    return _dataSource.deleteTujuanPengiriman(id);
  }
}
