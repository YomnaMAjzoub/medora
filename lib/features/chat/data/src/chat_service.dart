import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/features/chat/data/models/chat_message_model.dart';
import 'package:medora_git/features/chat/data/models/conversation_model.dart';

/// Firestore-backed chat between a patient and a doctor.
/// Conversation ids are deterministic (sorted participant ids), so a
/// patient-doctor pair always maps to one single document.
class ChatService {
  String? get _currentUserId =>
      GetStorage().read('user_id')?.toString();

  static String conversationId({
    required String patientId,
    required String doctorId,
  }) {
    final parts = [patientId, doctorId]..sort();
    return 'conversation_${parts.join('_')}';
  }

  Stream<List<ChatMessageModel>> streamMessages({
    required String doctorId,
  }) {
    final patientId = _currentUserId;
    if (patientId == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId(patientId: patientId, doctorId: doctorId))
        .collection('messages')
        .orderBy('created_at', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ChatMessageModel.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<ConversationModel?> streamConversation({
    required String doctorId,
  }) {
    final patientId = _currentUserId;
    if (patientId == null) return const Stream.empty();

    final ref = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId(patientId: patientId, doctorId: doctorId));

    return ref.snapshots().map(
          (snap) => snap.exists
              ? ConversationModel.fromFirestore(snap.id, snap.data()!)
              : null,
        );
  }

  /// Sorted in-memory to avoid requiring a Firestore composite index.
  Stream<List<ConversationModel>> streamConversations() {
    final patientId = _currentUserId;
    if (patientId == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('conversations')
        .where('patient_id', isEqualTo: patientId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) =>
                  ConversationModel.fromFirestore(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => (b.lastMessageAt ?? DateTime(0))
                .compareTo(a.lastMessageAt ?? DateTime(0))),
        );
  }

  Future<void> sendMessage({
    required String doctorId,
    required String text,
  }) async {
    final patientId = _currentUserId;
    if (patientId == null) {
      throw Exception('User id not found. Please login again.');
    }

    final db = FirebaseFirestore.instance;
    final conversationRef = db
        .collection('conversations')
        .doc(conversationId(patientId: patientId, doctorId: doctorId));

    await conversationRef.set({
      'patient_id': patientId,
      'doctor_id': doctorId,
      'last_message': text,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await conversationRef.collection('messages').add({
      'sender_id': patientId,
      'text': text,
      'created_at': FieldValue.serverTimestamp(),
      'read': false,
    });
  }
}
