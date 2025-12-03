import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/models/buah_raw_models.dart';
import 'package:wms_durich/features/warehouse/data/datasources/buah_raw_remote_data_source.dart';

final buahRawMockDataSourceProvider = Provider<BuahRawRemoteDataSource>((ref) {
  return BuahRawMockDataSourceImpl();
});

class BuahRawMockDataSourceImpl implements BuahRawRemoteDataSource {
  // Mock data generator
  List<BuahRawItem> _generateMockBuahRawItems({
    int count = 50,
    String? jenisDurianId,
    String? kodeBuahFilter,
    bool? isSorted,
  }) {
    final jenisList = [
      {'id': 'jenis-001', 'kode': 'MSW', 'nama': 'Musang King'},
      {'id': 'jenis-002', 'kode': 'BHM', 'nama': 'Black Thorn'},
      {'id': 'jenis-003', 'kode': 'D24', 'nama': 'D24'},
      {'id': 'jenis-004', 'kode': 'XO', 'nama': 'XO'},
    ];

    final lokasiList = [
      {
        'kodeLengkap': 'BLK-A01-P12',
        'blokId': 'blok-001',
        'blokNama': 'Blok A',
        'divisiNama': 'Divisi 1',
        'estateNama': 'Estate Utama',
        'companyNama': 'PT Durian Raya',
      },
      {
        'kodeLengkap': 'BLK-B02-P05',
        'blokId': 'blok-002',
        'blokNama': 'Blok B',
        'divisiNama': 'Divisi 2',
        'estateNama': 'Estate Selatan',
        'companyNama': 'PT Durian Raya',
      },
      {
        'kodeLengkap': 'BLK-C03-P18',
        'blokId': 'blok-003',
        'blokNama': 'Blok C',
        'divisiNama': 'Divisi 1',
        'estateNama': 'Estate Utara',
        'companyNama': 'PT Durian Raya',
      },
    ];

    final items = <BuahRawItem>[];
    for (int i = 0; i < count; i++) {
      final jenisData = jenisList[i % jenisList.length];
      final lokasiData = lokasiList[i % lokasiList.length];

      // Apply filter if specified
      if (jenisDurianId != null && jenisData['id'] != jenisDurianId) {
        continue;
      }

      final kodeBuah =
          '${jenisData['kode']}-${DateTime.now().year}-${(1000 + i).toString()}';

      // Apply kode buah filter
      if (kodeBuahFilter != null &&
          !kodeBuah.toLowerCase().contains(kodeBuahFilter.toLowerCase())) {
        continue;
      }

      final isSortedValue = isSorted ?? false;

      items.add(BuahRawItem(
        id: 'buah-raw-${i + 1}',
        kodeBuah: kodeBuah,
        jenisDurian: JenisDurianInfo(
          id: jenisData['id'] as String,
          kode: jenisData['kode'] as String,
          nama: jenisData['nama'] as String,
        ),
        lokasiPanen: LokasiPanenInfo(
          kodeLengkap: lokasiData['kodeLengkap'] as String,
          blokId: lokasiData['blokId'] as String,
          blokNama: lokasiData['blokNama'] as String,
          divisiNama: lokasiData['divisiNama'] as String,
          estateNama: lokasiData['estateNama'] as String,
          companyNama: lokasiData['companyNama'] as String,
        ),
        pohonPanen: 'pohon-${(i % 20) + 1}',
        tglPanen: DateTime.now()
            .subtract(Duration(days: i % 30))
            .toIso8601String()
            .split('T')[0],
        isSorted: isSortedValue,
        createdAt: DateTime.now().subtract(Duration(hours: i, minutes: i * 5)),
      ));
    }

    return items;
  }

  @override
  Future<BuahRawBulkResponse> createBulkBuahRaw(
      BuahRawBulkRequest request) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final items = <BuahRawItem>[];
    int counter = 0;

    for (final item in request.items) {
      for (int i = 0; i < item.jumlah; i++) {
        counter++;
        items.add(BuahRawItem(
          id: 'buah-raw-new-$counter',
          kodeBuah: 'NEW-${DateTime.now().year}-${(2000 + counter).toString()}',
          jenisDurian: JenisDurianInfo(
            id: item.jenisDurianId,
            kode: 'MSW',
            nama: 'Musang King',
          ),
          lokasiPanen: LokasiPanenInfo(
            kodeLengkap: 'BLK-A01-P12',
            blokId: 'blok-001',
            blokNama: 'Blok A',
            divisiNama: 'Divisi 1',
            estateNama: 'Estate Utama',
            companyNama: 'PT Durian Raya',
          ),
          pohonPanen: item.pohonPanenId,
          tglPanen: request.tglPanen ??
              DateTime.now().toIso8601String().split('T')[0],
          isSorted: false,
          createdAt: DateTime.now(),
        ));
      }
    }

    return BuahRawBulkResponse(
      items: items,
      totalInserted: counter,
    );
  }

  @override
  Future<UnsortedBuahResponse> getUnsortedBuahRaw({
    int page = 1,
    int limit = 50,
    String? kodeBuah,
    String? jenisDurianId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Generate mock data
    final allItems = _generateMockBuahRawItems(
      count: 120,
      jenisDurianId: jenisDurianId,
      kodeBuahFilter: kodeBuah,
      isSorted: false,
    );

    // Pagination
    final totalData = allItems.length;
    final totalPage = (totalData / limit).ceil();
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    final paginatedItems = allItems.sublist(
      startIndex,
      endIndex > totalData ? totalData : endIndex,
    );

    return UnsortedBuahResponse(
      data: paginatedItems,
      meta: PaginationMeta(
        page: page,
        limit: limit,
        totalData: totalData,
        totalPage: totalPage,
      ),
    );
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
    await Future.delayed(const Duration(milliseconds: 600));

    // Generate mock data
    final allItems = _generateMockBuahRawItems(
      count: 200,
      jenisDurianId: jenisDurianId,
      kodeBuahFilter: kodeBuah,
      isSorted: isSorted,
    );

    // Pagination
    final totalData = allItems.length;
    final totalPage = (totalData / limit).ceil();
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    final paginatedItems = allItems.sublist(
      startIndex,
      endIndex > totalData ? totalData : endIndex,
    );

    return UnsortedBuahResponse(
      data: paginatedItems,
      meta: PaginationMeta(
        page: page,
        limit: limit,
        totalData: totalData,
        totalPage: totalPage,
      ),
    );
  }
}
