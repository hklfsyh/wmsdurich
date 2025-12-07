import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/models/lot_models.dart';
import 'package:wms_durich/features/warehouse/data/datasources/lot_remote_data_source.dart';

final lotMockDataSourceProvider = Provider<LotRemoteDataSource>((ref) {
  return LotMockDataSourceImpl();
});

class LotMockDataSourceImpl implements LotRemoteDataSource {
  final Map<String, LotModel> _mockLots = {};
  final Map<String, List<LotDetailItem>> _mockLotItems = {};

  LotMockDataSourceImpl() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Create some initial lots
    final lot1 = LotModel(
      id: 'lot-001',
      kode: 'LOT-MSW-2024-001',
      jenisDurianId: 'jenis-001',
      jenisDurianNama: 'Musang King',
      kondisiBuah: 'Premium',
      beratAwal: 125.5,
      qtyAwal: 50,
      beratSisa: 125.5,
      qtySisa: 50,
      currentQty: 50,
      currentBerat: 125.5,
      status: 'ready',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    );

    final lot2 = LotModel(
      id: 'lot-002',
      kode: 'LOT-BHM-2024-002',
      jenisDurianId: 'jenis-002',
      jenisDurianNama: 'Black Thorn',
      kondisiBuah: 'Premium',
      beratAwal: 98.3,
      qtyAwal: 40,
      beratSisa: 98.3,
      qtySisa: 40,
      currentQty: 40,
      currentBerat: 98.3,
      status: 'ready',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    );

    final lot3 = LotModel(
      id: 'lot-003',
      kode: 'LOT-D24-2024-003',
      jenisDurianId: 'jenis-003',
      jenisDurianNama: 'D24',
      kondisiBuah: 'Standard',
      beratAwal: 0,
      qtyAwal: 0,
      beratSisa: 0,
      qtySisa: 0,
      currentQty: 15,
      currentBerat: 0,
      status: 'in_process',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    );

    _mockLots[lot1.id] = lot1;
    _mockLots[lot2.id] = lot2;
    _mockLots[lot3.id] = lot3;

    // Add some items to lots
    _mockLotItems[lot1.id] = [
      LotDetailItem(
        id: 'item-001',
        kodeBuah: 'MSW-2024-1001',
        tglPanen: DateTime.now().subtract(const Duration(days: 2)),
        asalBlok: 'BLK-A01',
        jenisDurian: 'MSW - Musang King',
        berat: 2.5,
      ),
      LotDetailItem(
        id: 'item-002',
        kodeBuah: 'MSW-2024-1002',
        tglPanen: DateTime.now().subtract(const Duration(days: 2)),
        asalBlok: 'BLK-A01',
        jenisDurian: 'MSW - Musang King',
        berat: 3.0,
      ),
    ];

    _mockLotItems[lot2.id] = [
      LotDetailItem(
        id: 'item-003',
        kodeBuah: 'BHM-2024-2001',
        tglPanen: DateTime.now().subtract(const Duration(days: 1)),
        asalBlok: 'BLK-B02',
        jenisDurian: 'BHM - Black Thorn',
        berat: 2.8,
      ),
    ];

    _mockLotItems[lot3.id] = [
      LotDetailItem(
        id: 'item-004',
        kodeBuah: 'D24-2024-3001',
        tglPanen: DateTime.now().subtract(const Duration(hours: 5)),
        asalBlok: 'BLK-C03',
        jenisDurian: 'D24 - D24',
        berat: 3.2,
      ),
    ];
  }

  @override
  Future<LotsResponse> getLots(
      {String? status, String? jenisDurianId, String? kondisi}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var lots = _mockLots.values.toList();

    // Apply filters
    if (status != null && status.isNotEmpty) {
      lots = lots.where((lot) => lot.status == status).toList();
    }
    if (jenisDurianId != null && jenisDurianId.isNotEmpty) {
      lots = lots.where((lot) => lot.jenisDurianId == jenisDurianId).toList();
    }
    if (kondisi != null && kondisi.isNotEmpty) {
      lots = lots.where((lot) => lot.kondisiBuah == kondisi).toList();
    }

    // Sort by created date descending
    lots.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return LotsResponse(data: lots);
  }

  @override
  Future<LotDetailResponse> getLotDetail(String lotId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final lot = _mockLots[lotId];
    if (lot == null) {
      throw Exception('Lot not found');
    }

    final items = _mockLotItems[lotId] ?? [];

    return LotDetailResponse(
      header: lot,
      items: items,
    );
  }

  @override
  Future<CreateLotResponse> createLot(CreateLotRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final lotId = 'lot-${DateTime.now().millisecondsSinceEpoch}';
    final lotNumber = _mockLots.length + 1;

    // Get jenis name
    final jenisMap = {
      'jenis-001': 'Musang King',
      'jenis-002': 'Black Thorn',
      'jenis-003': 'D24',
      'jenis-004': 'XO',
      'jenis-005': 'D101',
    };

    final jenisKodeMap = {
      'jenis-001': 'MSW',
      'jenis-002': 'BHM',
      'jenis-003': 'D24',
      'jenis-004': 'XO',
      'jenis-005': 'D101',
    };

    final jenisNama = jenisMap[request.jenisDurianId] ?? 'Unknown';
    final jenisKode = jenisKodeMap[request.jenisDurianId] ?? 'UNK';
    final lotKode =
        'LOT-$jenisKode-${DateTime.now().year}-${lotNumber.toString().padLeft(3, '0')}';

    final newLot = LotModel(
      id: lotId,
      kode: lotKode,
      jenisDurianId: request.jenisDurianId,
      jenisDurianNama: jenisNama,
      kondisiBuah: request.kondisiBuah,
      beratAwal: 0,
      qtyAwal: 0,
      beratSisa: 0,
      qtySisa: 0,
      currentQty: 0,
      currentBerat: 0,
      status: 'in_process',
      createdAt: DateTime.now(),
    );

    _mockLots[lotId] = newLot;
    _mockLotItems[lotId] = [];

    return CreateLotResponse(
      id: lotId,
      kode: lotKode,
      jenisDurianId: request.jenisDurianId,
      jenisDurianNama: jenisNama,
      kondisiBuah: request.kondisiBuah,
      status: 'in_process',
    );
  }

  @override
  Future<AddItemsToLotResponse> addItemsToLot(
      String lotId, AddItemsToLotRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final lot = _mockLots[lotId];
    if (lot == null) {
      throw Exception('Lot not found');
    }

    final items = _mockLotItems[lotId] ?? [];

    final newItem = LotDetailItem(
      id: 'item-${DateTime.now().millisecondsSinceEpoch}',
      kodeBuah:
          'BUAH-${DateTime.now().year}-${(items.length + 1).toString().padLeft(4, '0')}',
      tglPanen: DateTime.now(),
      asalBlok: 'BLK-${request.pohonKode}',
      jenisDurian: lot.jenisDurianNama,
      berat: request.berat,
    );

    items.add(newItem);
    _mockLotItems[lotId] = items;

    final updatedLot = LotModel(
      id: lot.id,
      kode: lot.kode,
      jenisDurianId: lot.jenisDurianId,
      jenisDurianNama: lot.jenisDurianNama,
      kondisiBuah: lot.kondisiBuah,
      beratAwal: lot.beratAwal,
      qtyAwal: lot.qtyAwal,
      beratSisa: lot.beratSisa,
      qtySisa: lot.qtySisa,
      currentQty: items.length,
      currentBerat: lot.currentBerat + request.berat,
      status: lot.status,
      createdAt: lot.createdAt,
    );

    _mockLots[lotId] = updatedLot;

    return AddItemsToLotResponse(currentQty: items.length);
  }

  @override
  Future<void> removeItemFromLot(
      String lotId, RemoveItemFromLotRequest request) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final lot = _mockLots[lotId];
    if (lot == null) {
      throw Exception('Lot not found');
    }

    final items = _mockLotItems[lotId] ?? [];
    items.removeWhere((item) => item.id == request.buahRawId);
    _mockLotItems[lotId] = items;

    final updatedLot = LotModel(
      id: lot.id,
      kode: lot.kode,
      jenisDurianId: lot.jenisDurianId,
      jenisDurianNama: lot.jenisDurianNama,
      kondisiBuah: lot.kondisiBuah,
      beratAwal: lot.beratAwal,
      qtyAwal: lot.qtyAwal,
      beratSisa: lot.beratSisa,
      qtySisa: lot.qtySisa,
      currentQty: items.length,
      currentBerat: lot.currentBerat,
      status: lot.status,
      createdAt: lot.createdAt,
    );

    _mockLots[lotId] = updatedLot;
  }

  @override
  Future<FinalizeLotResponse> finalizeLot(
      String lotId, FinalizeLotRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final lot = _mockLots[lotId];
    if (lot == null) {
      throw Exception('Lot not found');
    }

    final items = _mockLotItems[lotId] ?? [];
    final qtyTotal = items.length;
    final beratTotal = qtyTotal * 2.5;

    final updatedLot = LotModel(
      id: lot.id,
      kode: lot.kode,
      jenisDurianId: lot.jenisDurianId,
      jenisDurianNama: lot.jenisDurianNama,
      kondisiBuah: lot.kondisiBuah,
      beratAwal: beratTotal,
      qtyAwal: qtyTotal,
      beratSisa: beratTotal,
      qtySisa: qtyTotal,
      currentQty: qtyTotal,
      currentBerat: beratTotal,
      status: 'ready',
      createdAt: lot.createdAt,
    );

    _mockLots[lotId] = updatedLot;

    return FinalizeLotResponse(
      id: lotId,
      qtyTotal: qtyTotal,
      beratTotal: beratTotal,
      status: 'ready',
    );
  }
}
