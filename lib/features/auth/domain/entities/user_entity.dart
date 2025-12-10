class UserEntity {
  final List<String> roles;
  final String accessToken;
  final String? locationId;

  UserEntity({
    required this.roles,
    required this.accessToken,
    this.locationId,
  });
  
  bool get isAdmin => roles.contains('admin');
  bool get isWarehouse => roles.contains('warehouse');
  bool get isSales => roles.contains('sales');
  
  // Admin Pusat: Admin TANPA lokasi
  bool get isCentralAdmin => isAdmin && (locationId == null || locationId!.isEmpty);
  
  // Admin Cabang: Admin DENGAN lokasi
  bool get isBranchAdmin => isAdmin && (locationId != null && locationId!.isNotEmpty);

  // Helper untuk user dengan lokasi (Cabang & Staff Gudang)
  bool get hasLocation => locationId != null && locationId!.isNotEmpty;

  // Helper untuk menentukan apakah user adalah "Pusat" (Admin Pusat)
  bool get isCentralUser => isCentralAdmin;
  
  // Helper untuk menentukan apakah user adalah "Cabang" (Admin Cabang, Warehouse, Sales Cabang)
  bool get isBranchUser => hasLocation;
}
