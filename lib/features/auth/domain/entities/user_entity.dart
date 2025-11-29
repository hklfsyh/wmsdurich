class UserEntity {
  final List<String> roles;
  final String accessToken;

  UserEntity({
    required this.roles,
    required this.accessToken,
  });
  
  bool get isAdmin => roles.contains('admin');
  bool get isWarehouse => roles.contains('warehouse');
  bool get isSales => roles.contains('sales');
}
