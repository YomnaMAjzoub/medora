import 'package:medora_git/features/auth/data/models/user_model.dart';

class LoginResponseModel {
  const LoginResponseModel({
    required this.message,
    required this.accessToken,
    required this.tokenType,
    this.user,
  });

  final String message;
  final String accessToken;
  final String tokenType;

  /// Optional until the backend starts returning the user in the login
  /// response; when present, the app persists [UserModel.id] and role.
  final UserModel? user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: json['message'] as String,
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
