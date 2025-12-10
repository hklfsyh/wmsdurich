class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final List<String> roles;
  final String? currentLocationId;
  final int code;
  final bool success;
  final String message;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.roles,
    this.currentLocationId,
    required this.code,
    required this.success,
    required this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Parse 'code' (ensure it's an int)
    final int code = json['code'] is int 
        ? json['code'] 
        : int.tryParse(json['code']?.toString() ?? '200') ?? 200;
        
    // Parse 'success' (ensure it's a bool)
    final bool success = json['success'] is bool 
        ? json['success'] 
        : false;
        
    // Parse 'message' (ensure it's a string)
    final String message = json['message']?.toString() ?? '';

    // Parse 'data' (handle null or empty)
    final data = json['data'] ?? {};
    
    return AuthResponseModel(
      code: code,
      success: success,
      message: message,
      accessToken: data['access_token'] ?? '',
      refreshToken: data['refresh_token'] ?? '',
      // Handle roles being possibly null or empty in the data object
      roles: data['roles'] != null 
          ? List<String>.from(data['roles']) 
          : [],
      currentLocationId: data['current_location_id'],
    );
  }
}
