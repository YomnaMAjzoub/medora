import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.lastMessage,
    this.lastMessageAt,
  });

  final String id;
  final String patientId;
  final String doctorId;
  final String lastMessage;
  final DateTime? lastMessageAt;

  factory ConversationModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return ConversationModel(
      id: id,
      patientId: data['patient_id'] as String? ?? '',
      doctorId: data['doctor_id'] as String? ?? '',
      lastMessage: data['last_message'] as String? ?? '',
      lastMessageAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }
}
