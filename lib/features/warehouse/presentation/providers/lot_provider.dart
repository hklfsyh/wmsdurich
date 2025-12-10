import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/models/lot_models.dart';
import 'package:wms_durich/features/warehouse/data/repositories/lot_repository.dart';

class DraftLotsParams {
  final String? jenisDurianId;

  DraftLotsParams({this.jenisDurianId});

  DraftLotsParams copyWith({String? jenisDurianId}) {
    return DraftLotsParams(jenisDurianId: jenisDurianId ?? this.jenisDurianId);
  }
}

class DraftLotsParamsNotifier extends Notifier<DraftLotsParams> {
  @override
  DraftLotsParams build() => DraftLotsParams();

  void setJenisDurianId(String? jenisDurianId) {
    state = state.copyWith(jenisDurianId: jenisDurianId);
  }

  void reset() {
    state = DraftLotsParams();
  }
}

final draftLotsParamsProvider = NotifierProvider<DraftLotsParamsNotifier, DraftLotsParams>(
  DraftLotsParamsNotifier.new,
);

final draftLotsProvider = FutureProvider<LotsResponse>((ref) async {
  final params = ref.watch(draftLotsParamsProvider);
  final repository = ref.read(lotRepositoryProvider);
  return repository.getLots(
    status: 'DRAFT',
    jenisDurianId: params.jenisDurianId,
  );
});

final allDraftLotsProvider = FutureProvider<LotsResponse>((ref) async {
  final repository = ref.read(lotRepositoryProvider);
  return repository.getLots(status: 'DRAFT');
});

final allReadyLotsProvider = FutureProvider<LotsResponse>((ref) async {
  final repository = ref.read(lotRepositoryProvider);
  return repository.getLots(status: 'READY');
});

final allEmptyLotsProvider = FutureProvider<LotsResponse>((ref) async {
  final repository = ref.read(lotRepositoryProvider);
  return repository.getLots(status: 'EMPTY');
});

final lotDetailProvider = FutureProvider.family<LotDetailResponse, String>((ref, lotId) async {
  final repository = ref.read(lotRepositoryProvider);
  return repository.getLotDetail(lotId);
});

final createLotControllerProvider =
    AsyncNotifierProvider<CreateLotController, CreateLotResponse?>(CreateLotController.new);

class CreateLotController extends AsyncNotifier<CreateLotResponse?> {
  @override
  Future<CreateLotResponse?> build() async {
    return null;
  }

  Future<CreateLotResponse?> createLot(CreateLotRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(lotRepositoryProvider);
      return await repository.createLot(request);
    });
    return state.value;
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final addItemsToLotControllerProvider =
    AsyncNotifierProvider<AddItemsToLotController, AddItemsToLotResponse?>(AddItemsToLotController.new);

class AddItemsToLotController extends AsyncNotifier<AddItemsToLotResponse?> {
  @override
  Future<AddItemsToLotResponse?> build() async {
    return null;
  }

  Future<AddItemsToLotResponse?> addItems(String lotId, AddItemsToLotRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(lotRepositoryProvider);
      return await repository.addItemsToLot(lotId, request);
    });
    return state.value;
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final finalizeLotControllerProvider =
    AsyncNotifierProvider<FinalizeLotController, FinalizeLotResponse?>(FinalizeLotController.new);

class FinalizeLotController extends AsyncNotifier<FinalizeLotResponse?> {
  @override
  Future<FinalizeLotResponse?> build() async {
    return null;
  }

  Future<FinalizeLotResponse?> finalize(String lotId, FinalizeLotRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(lotRepositoryProvider);
      return await repository.finalizeLot(lotId, request);
    });
    return state.value;
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final removeItemFromLotControllerProvider =
    AsyncNotifierProvider<RemoveItemFromLotController, void>(RemoveItemFromLotController.new);

class RemoveItemFromLotController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    return;
  }

  Future<void> removeItem(String lotId, RemoveItemFromLotRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(lotRepositoryProvider);
      await repository.removeItemFromLot(lotId, request);
    });
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
