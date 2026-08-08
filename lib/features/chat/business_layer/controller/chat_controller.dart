import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/features/chat/data/models/chat_message_model.dart';
import 'package:medora_git/features/chat/data/models/conversation_model.dart';
import 'package:medora_git/features/chat/data/src/chat_service.dart';

class ChatController extends GetxController {
  ChatController({ChatService? chatService})
      : _chatService = chatService ?? ChatService();

  final ChatService _chatService;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString doctorId = ''.obs;
  final RxString conversationId = ''.obs;
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final Rx<ConversationModel?> conversation = Rx<ConversationModel?>(null);
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;

  String? get currentUserId =>
      GetStorage().read('user_id')?.toString();

  StreamSubscription<List<ChatMessageModel>>? _messagesSub;
  StreamSubscription<ConversationModel?>? _conversationSub;
  StreamSubscription<List<ConversationModel>>? _conversationsSub;

  /// Attaches the conversation-list stream (chat list screen).
  void loadConversations() {
    isLoading.value = true;
    errorMessage.value = '';
    _conversationsSub?.cancel();
    _conversationsSub = _chatService.streamConversations().listen(
          (items) {
            conversations.assignAll(items);
            isLoading.value = false;
          },
          onError: (e) {
            errorMessage.value = e.toString();
            isLoading.value = false;
          },
        );
  }

  /// Attaches the message stream for a given doctor chat.
  void openConversation({required String doctorId}) {
    this.doctorId.value = doctorId;
    isLoading.value = true;
    errorMessage.value = '';
    _messagesSub?.cancel();
    _conversationSub?.cancel();

    _messagesSub = _chatService.streamMessages(doctorId: doctorId).listen(
          (items) {
            messages.assignAll(items);
            isLoading.value = false;
          },
          onError: (e) {
            errorMessage.value = e.toString();
            isLoading.value = false;
          },
        );

    _conversationSub =
        _chatService.streamConversation(doctorId: doctorId).listen(
          (conv) {
            conversation.value = conv;
            conversationId.value = conv?.id ?? '';
          },
        );
  }

  Stream<List<ConversationModel>> streamConversations() {
    return _chatService.streamConversations();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || doctorId.value.isEmpty) return;

    try {
      await _chatService.sendMessage(
        doctorId: doctorId.value,
        text: trimmed,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  void onClose() {
    _messagesSub?.cancel();
    _conversationSub?.cancel();
    _conversationsSub?.cancel();
    super.onClose();
  }
}
