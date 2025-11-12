class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final String? attachmentUrl;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.attachmentUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      attachmentUrl: json['attachmentUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'attachmentUrl': attachmentUrl,
    };
  }
}

class ChatRoom {
  final String id;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isActive;

  ChatRoom({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.doctorName,
    required this.patientName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isActive = true,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      patientId: json['patientId'] as String,
      doctorName: json['doctorName'] as String,
      patientName: json['patientName'] as String,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'doctorName': doctorName,
      'patientName': patientName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'isActive': isActive,
    };
  }
}

enum MessageType { text, image, file, voice }

enum MessageStatus { sending, sent, delivered, read }

class ConsultationSession {
  final String id;
  final String chatRoomId;
  final String doctorId;
  final String patientId;
  final ConsultationType type;
  final ConsultationStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? cost;
  final String? notes;

  ConsultationSession({
    required this.id,
    required this.chatRoomId,
    required this.doctorId,
    required this.patientId,
    required this.type,
    this.status = ConsultationStatus.pending,
    this.startTime,
    this.endTime,
    this.cost,
    this.notes,
  });

  factory ConsultationSession.fromJson(Map<String, dynamic> json) {
    return ConsultationSession(
      id: json['id'] as String,
      chatRoomId: json['chatRoomId'] as String,
      doctorId: json['doctorId'] as String,
      patientId: json['patientId'] as String,
      type: ConsultationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      status: ConsultationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      cost: json['cost'] as double?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'doctorId': doctorId,
      'patientId': patientId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'cost': cost,
      'notes': notes,
    };
  }
}

enum ConsultationType { text, voice, video }

enum ConsultationStatus { pending, active, completed, cancelled }
