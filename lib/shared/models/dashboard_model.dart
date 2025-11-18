class DashboardModel {
  // Ringkasan Warehouse
  final int totalDurian;
  final int bagus;
  final int busuk;
  final int hilang;

  // Ringkasan Penjualan
  final double terjualKg;
  final double totalPendapatanJuta; // Dalam juta Rupiah, misal 3.8 = 3.8 juta
  final double pulpingKg;
  final int hilangPcs;

  DashboardModel({
    required this.totalDurian,
    required this.bagus,
    required this.busuk,
    required this.hilang,
    required this.terjualKg,
    required this.totalPendapatanJuta,
    required this.pulpingKg,
    required this.hilangPcs,
  });

  // Contoh data dummy
  static DashboardModel dummyData = DashboardModel(
    totalDurian: 4,
    bagus: 2,
    busuk: 1,
    hilang: 1,
    terjualKg: 25.5,
    totalPendapatanJuta: 3.8,
    pulpingKg: 5.2,
    hilangPcs: 3,
  );
}
