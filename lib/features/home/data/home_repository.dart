import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/shared/models/dashboard_model.dart';

// 1. Repository (Akan diganti dengan Dio call ke GoLang API di masa depan)
class HomeRepository {
  // Fungsi untuk mendapatkan data dashboard
  Future<DashboardModel> fetchDashboardData() async {
    // Simulasi delay jaringan
    await Future.delayed(const Duration(milliseconds: 500));

    // Mengembalikan data dummy
    return DashboardModel.dummyData;
  }
}

// 2. Provider untuk Repository
final homeRepositoryProvider = Provider((ref) => HomeRepository());

// 3. FutureProvider untuk mendapatkan data Dashboard
// Ini adalah cara Riverpod yang ideal untuk menangani data asinkronus (API)
final dashboardDataProvider = FutureProvider<DashboardModel>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.fetchDashboardData();
});
