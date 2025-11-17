import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat.dart';
import '../services/supabase_service.dart';
import '../config/supabase_config.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatRoom> _chatRooms = [];
  final Map<String, List<ChatMessage>> _messages = {};
  final Map<String, bool> _typingUsers = {};
  IO.Socket? _socket;
  bool _isConnected = false;

  List<ChatRoom> get chatRooms => List.unmodifiable(_chatRooms);
  bool get isConnected => _isConnected;

  List<ChatMessage> getMessages(String chatRoomId) {
    return List.unmodifiable(_messages[chatRoomId] ?? []);
  }

  bool isUserTyping(String chatRoomId) {
    return _typingUsers[chatRoomId] ?? false;
  }

  // Initialize socket connection - TODO: Implement proper real-time with Supabase
  void initializeSocket(String userId) {
    // For now, mark as connected for UI purposes
    _isConnected = true;
    notifyListeners();

    // TODO: Implement real-time messaging with Supabase subscriptions
    // Supabase doesn't have direct websocket support like socket.io
    // Would need to use Supabase real-time subscriptions for messages
  }

  // Load chat rooms for user
  Future<void> loadChatRooms(String userId) async {
    try {
      final chatRoomsData = await SupabaseService.getUserChatRooms(userId);
      _chatRooms.clear();
      _chatRooms.addAll(
        chatRoomsData.map((data) => ChatRoom.fromJson(data)).toList(),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chat rooms: $e');
      // Fallback to sample data if database fails
      _chatRooms.clear();
      _chatRooms.addAll([
        ChatRoom(
          id: 'room_001',
          doctorId: 'doc_001',
          patientId: userId,
          doctorName: 'الدكتور عامر السليمان',
          patientName: 'المريض',
          lastMessage: 'كيف حالك اليوم؟',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
          unreadCount: 2,
        ),
        ChatRoom(
          id: 'room_002',
          doctorId: 'doc_002',
          patientId: userId,
          doctorName: 'الدكتورة لينا الراشد',
          patientName: 'المريض',
          lastMessage: 'شكراً لك',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
          unreadCount: 0,
        ),
      ]);
      notifyListeners();
    }
  }

  // Load messages for a chat room
  Future<void> loadMessages(String chatRoomId) async {
    try {
      final messagesData = await SupabaseService.getChatMessages(chatRoomId);
      _messages[chatRoomId] = messagesData
          .map((data) => ChatMessage.fromJson(data))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading messages: $e');
      // Fallback to sample data if database fails
      _messages[chatRoomId] = [
        ChatMessage(
          id: 'msg_001',
          senderId: 'doc_001',
          receiverId: 'patient_001',
          message: 'مرحباً، كيف يمكنني مساعدتك؟',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          status: MessageStatus.read,
        ),
        ChatMessage(
          id: 'msg_002',
          senderId: 'patient_001',
          receiverId: 'doc_001',
          message: 'أشعر بألم في الصدر',
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
          status: MessageStatus.read,
        ),
        ChatMessage(
          id: 'msg_003',
          senderId: 'doc_001',
          receiverId: 'patient_001',
          message: 'منذ متى تشعر بهذا الألم؟',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          status: MessageStatus.delivered,
        ),
      ];
      notifyListeners();
    }
  }

  // Send a message
  Future<bool> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String message,
    MessageType type = MessageType.text,
    String? attachmentUrl,
  }) async {
    try {
      final chatMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: senderId,
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
        type: type,
        status: MessageStatus.sending,
        attachmentUrl: attachmentUrl,
      );

      // Add to local messages
      _addMessage(chatMessage);

      // Save to database
      final result = await SupabaseService.sendMessage(chatMessage.toJson());
      if (result != null) {
        // Update with server response if needed
        final serverMessage = ChatMessage.fromJson(result);
        _messages[chatRoomId]?[_messages[chatRoomId]!.indexWhere(
              (m) => m.id == chatMessage.id,
            )] =
            serverMessage;
        // Update status to sent
        _updateMessageStatus(chatMessage.id, MessageStatus.sent);
      } else {
        // If failed, keep as sending
        _updateMessageStatus(chatMessage.id, MessageStatus.sending);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      // Update status to failed or keep as sending
      return false;
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String chatRoomId, String userId) async {
    try {
      final messages = _messages[chatRoomId];
      if (messages != null) {
        for (int i = 0; i < messages.length; i++) {
          final message = messages[i];
          if (message.receiverId == userId &&
              message.status != MessageStatus.read) {
            messages[i] = ChatMessage(
              id: message.id,
              senderId: message.senderId,
              receiverId: message.receiverId,
              message: message.message,
              timestamp: message.timestamp,
              type: message.type,
              status: MessageStatus.read,
              attachmentUrl: message.attachmentUrl,
            );
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Create a new chat room
  Future<String?> createChatRoom({
    required String doctorId,
    required String patientId,
    required String doctorName,
    required String patientName,
  }) async {
    try {
      final chatRoom = ChatRoom(
        id: 'room_${DateTime.now().millisecondsSinceEpoch}',
        doctorId: doctorId,
        patientId: patientId,
        doctorName: doctorName,
        patientName: patientName,
      );

      // Save to database
      final result = await SupabaseService.createChatRoom(chatRoom.toJson());
      if (result != null) {
        final serverChatRoom = ChatRoom.fromJson(result);
        _chatRooms.add(serverChatRoom);
        notifyListeners();
        return serverChatRoom.id;
      }
      return null;
    } catch (e) {
      debugPrint('Error creating chat room: $e');
      return null;
    }
  }

  // Start a consultation session
  Future<bool> startConsultation({
    required String chatRoomId,
    required String doctorId,
    required String patientId,
    required ConsultationType type,
  }) async {
    try {
      final session = ConsultationSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        chatRoomId: chatRoomId,
        doctorId: doctorId,
        patientId: patientId,
        type: type,
        status: ConsultationStatus.active,
        startTime: DateTime.now(),
      );

      await SupabaseService.client
          .from('consultation_sessions')
          .insert(session.toJson());

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error starting consultation: $e');
      return false;
    }
  }

  // End a consultation session
  Future<bool> endConsultation(String sessionId) async {
    try {
      await SupabaseService.client
          .from('consultation_sessions')
          .update({
            'status': ConsultationStatus.completed.toString().split('.').last,
            'endTime': DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error ending consultation: $e');
      return false;
    }
  }

  void _addMessage(ChatMessage message) {
    final chatRoomId = _getChatRoomId(message.senderId, message.receiverId);
    if (chatRoomId != null) {
      _messages.putIfAbsent(chatRoomId, () => []).add(message);
      notifyListeners();
    }
  }

  void _updateMessageStatus(String messageId, MessageStatus status) {
    for (final messages in _messages.values) {
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].id == messageId) {
          messages[i] = ChatMessage(
            id: messages[i].id,
            senderId: messages[i].senderId,
            receiverId: messages[i].receiverId,
            message: messages[i].message,
            timestamp: messages[i].timestamp,
            type: messages[i].type,
            status: status,
            attachmentUrl: messages[i].attachmentUrl,
          );
          notifyListeners();
          return;
        }
      }
    }
  }

  String? _getChatRoomId(String userId1, String userId2) {
    return _chatRooms
        .where(
          (room) =>
              (room.doctorId == userId1 && room.patientId == userId2) ||
              (room.doctorId == userId2 && room.patientId == userId1),
        )
        .firstOrNull
        ?.id;
  }

  // Send typing indicator - TODO: Implement with Supabase real-time
  void sendTypingStatus(String chatRoomId, bool isTyping) {
    // For now, just update local state
    _typingUsers[chatRoomId] = isTyping;
    notifyListeners();
  }

  // Delete a message
  Future<bool> deleteMessage(String chatRoomId, String messageId) async {
    try {
      // Remove from local messages
      final messages = _messages[chatRoomId];
      if (messages != null) {
        messages.removeWhere((message) => message.id == messageId);
        notifyListeners();
      }

      // Delete from database
      await SupabaseService.deleteMessage(messageId);

      return true;
    } catch (e) {
      debugPrint('Error deleting message: $e');
      return false;
    }
  }

  // Dispose socket connection
  void dispose() {
    _socket?.disconnect();
    _socket = null;
  }
}
