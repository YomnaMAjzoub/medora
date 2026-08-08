import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.createdAt,
    this.read = false,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;
  final bool read;

  factory ChatMessageModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return ChatMessageModel(
      id: id,
      senderId: data['sender_id'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      read: data['read'] as bool? ?? false,
    );
  }
}
