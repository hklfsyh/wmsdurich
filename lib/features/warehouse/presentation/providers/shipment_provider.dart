import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/models/shipment_models.dart';
import 'package:wms_durich/features/warehouse/data/models/lot_models.dart';

// State class for managing shipments
class ShipmentState {
  final List<ShipmentModel> shipments;
  final Map<String, List<ShipmentItemModel>> shipmentItems;
  final List<LotModel> availableLots;
  final bool isLoading;
  final String? error;

  ShipmentState({
    required this.shipments,
    required this.shipmentItems,
    required this.availableLots,
    this.isLoading = false,
    this.error,
  });

  ShipmentState copyWith({
    List<ShipmentModel>? shipments,
    Map<String, List<ShipmentItemModel>>? shipmentItems,
    List<LotModel>? availableLots,
    bool? isLoading,
    String? error,
  }) {
    return ShipmentState(
      shipments: shipments ?? this.shipments,
      shipmentItems: shipmentItems ?? this.shipmentItems,
      availableLots: availableLots ?? this.availableLots,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<ShipmentModel> get draftShipments =>
      shipments.where((s) => s.status == 'DRAFT').toList();

  List<ShipmentModel> get historyShipments =>
      shipments.where((s) => s.status != 'DRAFT').toList();
}

class ShipmentNotifier extends Notifier<ShipmentState> {
  @override
  ShipmentState build() {
    return ShipmentState(
      shipments: _getDummyShipments(),
      shipmentItems: _getDummyShipmentItems(),
      availableLots: _getDummyAvailableLots(),
    );
  }

  List<ShipmentModel> _getDummyShipments() {
    return [
      ShipmentModel(
        id: 'SHIP001',
        tujuan: 'Gudang Jakarta Pusat',
        tglKirim: DateTime.now(),
        status: 'DRAFT',
        totalItems: 2,
        totalBerat: 150.5,
        createdBy: 'Admin',
        createdAt: DateTime.now(),
      ),
      ShipmentModel(
        id: 'SHIP002',
        tujuan: 'Toko Bandung',
        tglKirim: DateTime.now().subtract(const Duration(days: 1)),
        status: 'SENDING',
        totalItems: 3,
        totalBerat: 220.0,
        createdBy: 'Admin',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ShipmentModel(
        id: 'SHIP003',
        tujuan: 'Gudang Surabaya',
        tglKirim: DateTime.now().subtract(const Duration(days: 3)),
        status: 'COMPLETED',
        totalItems: 5,
        totalBerat: 450.0,
        createdBy: 'Warehouse',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  Map<String, List<ShipmentItemModel>> _getDummyShipmentItems() {
    return {
      'SHIP001': [
        ShipmentItemModel(
          id: 'ITEM001',
          lotId: 'LOT001',
          lotKode: 'LOT-2024-001',
          jenisDurian: 'Musang King',
          kondisiBuah: 'Segar',
          qtyAmbil: 50,
          beratAmbil: 75.5,
        ),
        ShipmentItemModel(
          id: 'ITEM002',
          lotId: 'LOT002',
          lotKode: 'LOT-2024-002',
          jenisDurian: 'Monthong',
          kondisiBuah: 'Segar',
          qtyAmbil: 40,
          beratAmbil: 75.0,
        ),
      ],
      'SHIP002': [
        ShipmentItemModel(
          id: 'ITEM003',
          lotId: 'LOT003',
          lotKode: 'LOT-2024-003',
          jenisDurian: 'Bawor',
          kondisiBuah: 'Matang',
          qtyAmbil: 30,
          beratAmbil: 80.0,
        ),
      ],
    };
  }

  List<LotModel> _getDummyAvailableLots() {
    return [
      LotModel(
        id: 'LOT004',
        kode: 'LOT-2024-004',
        jenisDurianId: 'JD001',
        jenisDurianNama: 'Musang King',
        kondisiBuah: 'Segar',
        beratAwal: 200.0,
        qtyAwal: 100,
        beratSisa: 180.0,
        qtySisa: 85,
        currentQty: 85,
        status: 'READY',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      LotModel(
        id: 'LOT005',
        kode: 'LOT-2024-005',
        jenisDurianId: 'JD002',
        jenisDurianNama: 'Monthong',
        kondisiBuah: 'Matang',
        beratAwal: 150.0,
        qtyAwal: 80,
        beratSisa: 150.0,
        qtySisa: 80,
        currentQty: 80,
        status: 'READY',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      LotModel(
        id: 'LOT006',
        kode: 'LOT-2024-006',
        jenisDurianId: 'JD003',
        jenisDurianNama: 'Bawor',
        kondisiBuah: 'Segar',
        beratAwal: 250.0,
        qtyAwal: 120,
        beratSisa: 200.0,
        qtySisa: 95,
        currentQty: 95,
        status: 'READY',
        createdAt: DateTime.now(),
      ),
      LotModel(
        id: 'LOT007',
        kode: 'LOT-2024-007',
        jenisDurianId: 'JD001',
        jenisDurianNama: 'Musang King',
        kondisiBuah: 'Matang',
        beratAwal: 180.0,
        qtyAwal: 90,
        beratSisa: 180.0,
        qtySisa: 90,
        currentQty: 90,
        status: 'READY',
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<ShipmentModel> createShipment({
    required String tujuan,
    required DateTime tglKirim,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newId = 'SHIP${DateTime.now().millisecondsSinceEpoch}';
    final newShipment = ShipmentModel(
      id: newId,
      tujuan: tujuan,
      tglKirim: tglKirim,
      status: 'DRAFT',
      totalItems: 0,
      totalBerat: 0,
      createdBy: 'User',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      shipments: [...state.shipments, newShipment],
      shipmentItems: Map<String, List<ShipmentItemModel>>.from(state.shipmentItems)
        ..[newId] = [],
    );

    return newShipment;
  }

  Future<void> addItemToShipment({
    required String shipmentId,
    required LotModel lot,
    required int qty,
    required double berat,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newItem = ShipmentItemModel(
      id: 'ITEM${DateTime.now().millisecondsSinceEpoch}',
      lotId: lot.id,
      lotKode: lot.kode,
      jenisDurian: lot.jenisDurianNama,
      kondisiBuah: lot.kondisiBuah,
      qtyAmbil: qty,
      beratAmbil: berat,
    );

    final currentItems = state.shipmentItems[shipmentId] ?? [];
    final updatedItems = Map<String, List<ShipmentItemModel>>.from(state.shipmentItems);
    updatedItems[shipmentId] = [...currentItems, newItem];

    final updatedShipments = state.shipments.map((s) {
      if (s.id == shipmentId) {
        return ShipmentModel(
          id: s.id,
          tujuan: s.tujuan,
          tglKirim: s.tglKirim,
          status: s.status,
          totalItems: s.totalItems + 1,
          totalBerat: s.totalBerat + berat,
          createdBy: s.createdBy,
          createdAt: s.createdAt,
        );
      }
      return s;
    }).toList();

    state = state.copyWith(
      shipments: updatedShipments,
      shipmentItems: updatedItems,
    );
  }

  Future<void> removeItemFromShipment({
    required String shipmentId,
    required String itemId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final currentItems = state.shipmentItems[shipmentId] ?? [];
    final removedItem = currentItems.firstWhere((i) => i.id == itemId);
    final updatedItemsList = currentItems.where((i) => i.id != itemId).toList();

    final updatedItems = Map<String, List<ShipmentItemModel>>.from(state.shipmentItems);
    updatedItems[shipmentId] = updatedItemsList;

    final updatedShipments = state.shipments.map((s) {
      if (s.id == shipmentId) {
        return ShipmentModel(
          id: s.id,
          tujuan: s.tujuan,
          tglKirim: s.tglKirim,
          status: s.status,
          totalItems: s.totalItems - 1,
          totalBerat: s.totalBerat - removedItem.beratAmbil,
          createdBy: s.createdBy,
          createdAt: s.createdAt,
        );
      }
      return s;
    }).toList();

    state = state.copyWith(
      shipments: updatedShipments,
      shipmentItems: updatedItems,
    );
  }

  Future<void> finalizeShipment(String shipmentId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final updatedShipments = state.shipments.map((s) {
      if (s.id == shipmentId) {
        return ShipmentModel(
          id: s.id,
          tujuan: s.tujuan,
          tglKirim: s.tglKirim,
          status: 'SENDING',
          totalItems: s.totalItems,
          totalBerat: s.totalBerat,
          createdBy: s.createdBy,
          createdAt: s.createdAt,
        );
      }
      return s;
    }).toList();

    state = state.copyWith(shipments: updatedShipments);
  }

  Future<void> cancelShipment(String shipmentId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final updatedShipments = state.shipments.map((s) {
      if (s.id == shipmentId) {
        return ShipmentModel(
          id: s.id,
          tujuan: s.tujuan,
          tglKirim: s.tglKirim,
          status: 'CANCELLED',
          totalItems: s.totalItems,
          totalBerat: s.totalBerat,
          createdBy: s.createdBy,
          createdAt: s.createdAt,
        );
      }
      return s;
    }).toList();

    state = state.copyWith(shipments: updatedShipments);
  }

  Future<void> deleteShipment(String shipmentId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final updatedShipments = state.shipments.where((s) => s.id != shipmentId).toList();
    final updatedItems = Map<String, List<ShipmentItemModel>>.from(state.shipmentItems);
    updatedItems.remove(shipmentId);

    state = state.copyWith(
      shipments: updatedShipments,
      shipmentItems: updatedItems,
    );
  }
}

final shipmentProvider = NotifierProvider<ShipmentNotifier, ShipmentState>(
  ShipmentNotifier.new,
);

final shipmentDetailProvider =
    Provider.family<ShipmentModel?, String>((ref, shipmentId) {
  final shipmentState = ref.watch(shipmentProvider);
  try {
    return shipmentState.shipments.firstWhere((s) => s.id == shipmentId);
  } catch (_) {
    return null;
  }
});

final shipmentItemsProvider =
    Provider.family<List<ShipmentItemModel>, String>((ref, shipmentId) {
  final shipmentState = ref.watch(shipmentProvider);
  return shipmentState.shipmentItems[shipmentId] ?? [];
});

final availableLotsForShipmentProvider = Provider<List<LotModel>>((ref) {
  final shipmentState = ref.watch(shipmentProvider);
  return shipmentState.availableLots;
});
