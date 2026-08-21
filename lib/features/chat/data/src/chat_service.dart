import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/features/chat/data/models/chat_message_model.dart';
import 'package:medora_git/features/chat/data/models/conversation_model.dart';

/// Firestore-backed chat between a patient and a doctor.
/// Conversation ids are deterministic (sorted participant ids), so a
/// patient-doctor pair always maps to one single document.
///
/// Both roles use the same methods: the caller passes the *other* party id
/// and the current user's role (stored at login) decides who is the patient
/// and who is the doctor in the conversation.
class ChatService {
  String? get _currentUserId =>
      GetStorage().read('user_id')?.toString();

  bool get _isDoctor => GetStorage().read('role') == 'doctor';

  static String conversationId({
    required String patientId,
    required String doctorId,
  }) {
    final parts = [patientId, doctorId]..sort();
    return 'conversation_${parts.join('_')}';
  }

  /// Resolves the conversation participants for the current user. [otherId]
  /// is the id of the other party (a doctor for patients, a patient for
  /// doctors).
  ({String patientId, String doctorId, String myId}) _participants(
    String otherId,
  ) {
    final myId = _currentUserId ?? '';
    if (_isDoctor) return (patientId: otherId, doctorId: myId, myId: myId);
    return (patientId: myId, doctorId: otherId, myId: myId);
  }

  Stream<List<ChatMessageModel>> streamMessages({
    required String otherPartyId,
  }) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return const Stream.empty();
    final participants = _participants(otherPartyId);

    return FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId(
          patientId: participants.patientId,
          doctorId: participants.doctorId,
        ))
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
    required String otherPartyId,
  }) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return const Stream.empty();
    final participants = _participants(otherPartyId);

    final ref = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId(
          patientId: participants.patientId,
          doctorId: participants.doctorId,
        ));

    return ref.snapshots().map(
          (snap) => snap.exists
              ? ConversationModel.fromFirestore(snap.id, snap.data()!)
              : null,
        );
  }

  /// Sorted in-memory to avoid requiring a Firestore composite index.
  /// Patients see conversations where they are the patient; doctors see
  /// conversations where they are the doctor.
  Stream<List<ConversationModel>> streamConversations() {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return const Stream.empty();

    final field = _isDoctor ? 'doctor_id' : 'patient_id';

    return FirebaseFirestore.instance
        .collection('conversations')
        .where(field, isEqualTo: currentUserId)
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
    required String otherPartyId,
    required String text,
  }) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      throw Exception('user_id_not_found'.tr());
    }
    final participants = _participants(otherPartyId);

    final db = FirebaseFirestore.instance;
    final conversationRef = db
        .collection('conversations')
        .doc(conversationId(
          patientId: participants.patientId,
          doctorId: participants.doctorId,
        ));

    await conversationRef.set({
      'patient_id': participants.patientId,
      'doctor_id': participants.doctorId,
      'last_message': text,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await conversationRef.collection('messages').add({
      'sender_id': currentUserId,
      'text': text,
      'created_at': FieldValue.serverTimestamp(),
      'read': false,
    });
  }
}
