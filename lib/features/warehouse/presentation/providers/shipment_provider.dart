import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/models/shipment_models.dart';
import 'package:wms_durich/features/warehouse/data/models/lot_models.dart';
import 'package:wms_durich/features/warehouse/data/repositories/shipment_repository.dart';
import 'package:wms_durich/features/warehouse/data/repositories/lot_repository.dart';

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
  late ShipmentRepository _repository;
  late LotRepository _lotRepository;

  @override
  ShipmentState build() {
    _repository = ref.read(shipmentRepositoryProvider);
    _lotRepository = ref.read(lotRepositoryProvider);

    // Remove _fetchInitialData() to prevent double fetch
    // Pages (ShipmentListPage & IncomingShipmentsPage) are now responsible 
    // for initiating the fetch with correct filters in their initState/build.
    
    return ShipmentState(
      shipments: [],
      shipmentItems: {},
      availableLots: [],
      // Don't set isLoading true initially, wait for explicit fetch
      isLoading: false, 
    );
  }

  // Removed _fetchInitialData as it causes default fetch without filters


  Future<void> refreshShipments({String? status, String? type}) async {
    state = state.copyWith(isLoading: true);
    try {
      final shipments = await _repository.getShipments(status: status, type: type);
      state = state.copyWith(
        shipments: shipments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchShipmentDetail(String id) async {
    try {
      final detail = await _repository.getShipmentDetail(id);

      // Update shipments list with latest header info
      final updatedShipments = state.shipments.map((s) {
        return s.id == id ? detail.header : s;
      }).toList();

      // If not in list (e.g. just created or filtered out), add it
      if (!updatedShipments.any((s) => s.id == id)) {
        updatedShipments.add(detail.header);
      }

      // Update items map
      final updatedItems =
          Map<String, List<ShipmentItemModel>>.from(state.shipmentItems);
      updatedItems[id] = detail.items;

      state = state.copyWith(
        shipments: updatedShipments,
        shipmentItems: updatedItems,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fetchAvailableLots() async {
    try {
      final response = await _lotRepository.getLots(status: 'READY');
      state = state.copyWith(availableLots: response.data);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<ShipmentModel> createShipment({
    required String tujuanId,
    required DateTime tglKirim,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final newShipment = await _repository.createShipment(tujuanId, tglKirim);

      // Add to list
      state = state.copyWith(
        shipments: [newShipment, ...state.shipments],
        shipmentItems:
            Map<String, List<ShipmentItemModel>>.from(state.shipmentItems)
              ..[newShipment.id] = [],
        isLoading: false,
      );

      return newShipment;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> addItemToShipment({
    required String shipmentId,
    required LotModel lot,
    required int qty,
    required double berat,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.addItemToShipment(shipmentId, lot.id, qty, berat);

      // Refresh detail to get updated totals and items
      await fetchShipmentDetail(shipmentId);
      // Refresh available lots as stock decreased
      await fetchAvailableLots();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> removeItemFromShipment({
    required String shipmentId,
    required String itemId,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.removeItemFromShipment(shipmentId, itemId);

      // Refresh detail
      await fetchShipmentDetail(shipmentId);
      // Refresh available lots as stock returned
      await fetchAvailableLots();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> finalizeShipment(String shipmentId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.finalizeShipment(shipmentId);
      await refreshShipments();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> cancelShipment(String shipmentId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.cancelShipment(shipmentId);
      await refreshShipments();
      // Also refresh available lots because cancelled shipment returns stock
      await fetchAvailableLots();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
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

// Provider untuk verify incoming shipment page
final verifyShipmentDetailProvider =
    FutureProvider.family<ShipmentDetailResponse, String>(
        (ref, shipmentId) async {
  final repository = ref.read(shipmentRepositoryProvider);
  // Fetch shipment detail dari API
  final detail = await repository.getShipmentDetail(shipmentId);
  return detail;
});
