import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/warehouse/data/models/master_data_models.dart';
import 'package:wms_durich/features/warehouse/data/repositories/master_data_repository.dart';

final bloksProvider = FutureProvider<List<BlokModel>>((ref) async {
  final repository = ref.read(masterDataRepositoryProvider);
  return repository.getBloks();
});

final jenisDurianProvider = FutureProvider<List<JenisDurianModel>>((ref) async {
  final repository = ref.read(masterDataRepositoryProvider);
  return repository.getJenisDurian();
});

final pohonProvider = FutureProvider<List<PohonModel>>((ref) async {
  final repository = ref.read(masterDataRepositoryProvider);
  return repository.getPohon();
});

final warehouseDataProvider = FutureProvider<WarehouseDataModel>((ref) async {
  final repository = ref.read(masterDataRepositoryProvider);
  return repository.getWarehouseData();
});
