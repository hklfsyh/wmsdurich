import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/models/buah_raw_models.dart';
import 'package:wms_durich/features/warehouse/data/repositories/buah_raw_repository.dart';

final createBulkBuahRawControllerProvider =
    AsyncNotifierProvider<CreateBulkBuahRawController, BuahRawBulkResponse?>(
        CreateBulkBuahRawController.new);

class CreateBulkBuahRawController extends AsyncNotifier<BuahRawBulkResponse?> {
  @override
  Future<BuahRawBulkResponse?> build() async {
    return null;
  }

  Future<BuahRawBulkResponse?> createBulk(BuahRawBulkRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(buahRawRepositoryProvider);
      return await repository.createBulkBuahRaw(request);
    });
    return state.value;
  }
}

class UnsortedBuahParams {
  final int page;
  final int limit;
  final String? kodeBuah;
  final String? jenisDurianId;

  UnsortedBuahParams({
    this.page = 1,
    this.limit = 10,
    this.kodeBuah,
    this.jenisDurianId,
  });

  UnsortedBuahParams copyWith({
    int? page,
    int? limit,
    String? kodeBuah,
    String? jenisDurianId,
    bool clearJenisDurian = false,
  }) {
    return UnsortedBuahParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      kodeBuah: kodeBuah ?? this.kodeBuah,
      jenisDurianId: clearJenisDurian ? null : (jenisDurianId ?? this.jenisDurianId),
    );
  }
}

class UnsortedBuahParamsNotifier extends Notifier<UnsortedBuahParams> {
  @override
  UnsortedBuahParams build() => UnsortedBuahParams();

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void setSearch(String? kodeBuah) {
    state = UnsortedBuahParams(
      page: 1,
      limit: state.limit,
      kodeBuah: kodeBuah,
      jenisDurianId: state.jenisDurianId,
    );
  }

  void setJenisDurianId(String? jenisDurianId) {
    state = UnsortedBuahParams(
      page: 1,
      limit: state.limit,
      kodeBuah: state.kodeBuah,
      jenisDurianId: jenisDurianId,
    );
  }

  void reset() {
    state = UnsortedBuahParams();
  }
}

final unsortedBuahParamsProvider = NotifierProvider<UnsortedBuahParamsNotifier, UnsortedBuahParams>(
  UnsortedBuahParamsNotifier.new,
);

final unsortedBuahProvider = FutureProvider<UnsortedBuahResponse>((ref) async {
  final params = ref.watch(unsortedBuahParamsProvider);
  final repository = ref.read(buahRawRepositoryProvider);
  return repository.getUnsortedBuahRaw(
    page: params.page,
    limit: params.limit,
    kodeBuah: params.kodeBuah,
    jenisDurianId: params.jenisDurianId,
  );
});
