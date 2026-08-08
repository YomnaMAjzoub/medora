import 'package:medora_git/features/auth/data/models/user_model.dart';

class RegisterResponseModel {
  const RegisterResponseModel({required this.message, required this.user});

  final String message;
  final UserModel user;

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: json['message'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
