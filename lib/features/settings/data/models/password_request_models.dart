class UpdatePasswordRequest {
  final String oldPassword;
  final String newPassword;

  UpdatePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'old_password': oldPassword,
        'new_password': newPassword,
      };
}

class ResetPasswordRequest {
  final String email;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'new_password': newPassword,
      };
}
