class AppConfirmResponseModel {
  const AppConfirmResponseModel({
    required this.status,
    required this.message,
    required this.paymentUrl,
  });

  final String status;
  final String message;
  final String paymentUrl;

  factory AppConfirmResponseModel.fromJson(Map<String, dynamic> json) {
    return AppConfirmResponseModel(
      status: json['status'] as String,
      message: json['message'] as String,
      paymentUrl: json['payment_url'] as String,
    );
  }
}
