import 'package:eschool_saas_staff/data/models/chat/chatUser.dart';

class ChatContact {
  const ChatContact({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    required this.updatedAt,
    required this.unreadCount,
    required this.lastMessage,
    // required this.lastMessageReadAt,
    // required this.lastMessageType,
    // required this.lastAttachmentFile,
    required this.user,
  });

  ChatContact.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        senderId = json['sender_id'] as int,
        receiverId = json['receiver_id'] as int,
        createdAt = json['created_at'] as String,
        updatedAt = json['updated_at'] as String,
        unreadCount = json['unread_count'] as int,
        lastMessage = json['last_message'] as String?,
        // lastMessageReadAt = json['last_message_read_at'] != null
        //     ? DateTime.tryParse(json['last_message_read_at'] as String)
        //     : null,
        // lastMessageType = json['last_message_type'] as String?,
        // lastAttachmentFile = (json['last_attachment']
        //     as Map<String, dynamic>?)?['file'] as String?,
        user = ChatUser.fromJson(json['user']);

  final int id;
  final int senderId;
  final int receiverId;
  final String createdAt;
  final String updatedAt;
  final int unreadCount;
  final String? lastMessage;
  // final DateTime? lastMessageReadAt;
  // final String? lastMessageType;
  // final String? lastAttachmentFile;
  final ChatUser user;

  ChatContact copyWith({
    int? id,
    int? senderId,
    int? receiverId,
    String? createdAt,
    String? updatedAt,
    int? unreadCount,
    String? lastMessage,
    // DateTime? lastMessageReadAt,
    // String? lastAttachmentFile,
    ChatUser? user,
  }) {
    return ChatContact(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      // lastMessageReadAt: lastMessageReadAt ?? this.lastMessageReadAt,
      // lastMessageType: lastMessageType ?? this.lastMessageType,
      // lastAttachmentFile: lastAttachmentFile ?? this.lastAttachmentFile,
      user: user ?? this.user,
    );
  }
}
