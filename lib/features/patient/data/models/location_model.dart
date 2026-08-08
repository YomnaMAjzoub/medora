class AddLocationResponseModel {
  const AddLocationResponseModel({
    required this.message,
    required this.location,
  });

  final String message;
  final LocationModel location;

  factory AddLocationResponseModel.fromJson(Map<String, dynamic> json) {
    return AddLocationResponseModel(
      message: json['message'] as String,
      location: LocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
    );
  }
}

class LocationModel {
  const LocationModel({
    required this.id,
    required this.userId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final String address;
  final String latitude;
  final String longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      address: json['address'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
