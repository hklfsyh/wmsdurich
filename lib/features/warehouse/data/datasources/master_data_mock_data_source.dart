import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/models/master_data_models.dart';
import 'package:wms_durich/features/warehouse/data/datasources/master_data_remote_data_source.dart';

final masterDataMockDataSourceProvider =
    Provider<MasterDataRemoteDataSource>((ref) {
  return MasterDataMockDataSourceImpl();
});

class MasterDataMockDataSourceImpl implements MasterDataRemoteDataSource {
  @override
  Future<List<BlokModel>> getBloks() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      BlokModel(
        id: 'blok-001',
        kode: 'A01',
        namaBlok: 'Blok A',
        kodeLengkap: 'BLK-A01',
      ),
      BlokModel(
        id: 'blok-002',
        kode: 'B02',
        namaBlok: 'Blok B',
        kodeLengkap: 'BLK-B02',
      ),
      BlokModel(
        id: 'blok-003',
        kode: 'C03',
        namaBlok: 'Blok C',
        kodeLengkap: 'BLK-C03',
      ),
      BlokModel(
        id: 'blok-004',
        kode: 'D04',
        namaBlok: 'Blok D',
        kodeLengkap: 'BLK-D04',
      ),
    ];
  }

  @override
  Future<List<JenisDurianModel>> getJenisDurian() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      JenisDurianModel(
        id: 'jenis-001',
        kode: 'MSW',
        namaJenis: 'Musang King',
      ),
      JenisDurianModel(
        id: 'jenis-002',
        kode: 'BHM',
        namaJenis: 'Black Thorn',
      ),
      JenisDurianModel(
        id: 'jenis-003',
        kode: 'D24',
        namaJenis: 'D24',
      ),
      JenisDurianModel(
        id: 'jenis-004',
        kode: 'XO',
        namaJenis: 'XO',
      ),
      JenisDurianModel(
        id: 'jenis-005',
        kode: 'D101',
        namaJenis: 'D101',
      ),
    ];
  }

  @override
  Future<List<PohonModel>> getPohon() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final pohonList = <PohonModel>[];

    // Generate pohon untuk setiap blok
    final bloks = ['A01', 'B02', 'C03', 'D04'];

    for (final blokKode in bloks) {
      for (int i = 1; i <= 20; i++) {
        final pohonKode = 'P${i.toString().padLeft(2, '0')}';
        pohonList.add(PohonModel(
          id: 'pohon-${blokKode.toLowerCase()}-$i',
          kode: pohonKode,
          nama: 'Pohon $pohonKode',
          kodeLengkap: 'BLK-$blokKode-$pohonKode',
          blokId: 'blok-${bloks.indexOf(blokKode) + 1}'.padLeft(3, '0'),
        ));
      }
    }

    return pohonList;
  }

  @override
  Future<WarehouseDataModel> getWarehouseData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return WarehouseDataModel(
      totalBuahRawToday: 245,
      totalLotReady: 18,
      totalLotSent: 42,
    );
  }
}
