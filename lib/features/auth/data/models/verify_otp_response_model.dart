import 'package:medora_git/features/auth/data/models/user_model.dart';

class VerifyOtpResponseModel {
  const VerifyOtpResponseModel({required this.message, required this.user});

  final String message;
  final UserModel user;

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      message: json['message'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
