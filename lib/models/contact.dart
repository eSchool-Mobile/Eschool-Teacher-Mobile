class Contact {
  final int id;
  final String name;
  final String email;
  final String subject;
  final String message;
  final String type; // 'inquiry' or 'report'
  final String status; // 'new', 'replied', 'closed'
  final int? userId;
  final String createdAt;
  final String? updatedAt;
  final List<ContactReply>? replies;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.type,
    required this.status,
    this.userId,
    required this.createdAt,
    this.updatedAt,
    this.replies,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'inquiry',
      status: json['status'] ?? 'new',
      userId: json['user_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((reply) => ContactReply.fromJson(reply))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      'type': type,
      'status': status,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (replies != null)
        'replies': replies!.map((reply) => reply.toJson()).toList(),
    };
  }

  Contact copyWith({
    int? id,
    String? name,
    String? email,
    String? subject,
    String? message,
    String? type,
    String? status,
    int? userId,
    String? createdAt,
    String? updatedAt,
    List<ContactReply>? replies,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      type: type ?? this.type,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
    );
  }

  // Helper getters
  bool get isInquiry => type == 'inquiry';
  bool get isReport => type == 'report';
  bool get isNew => status == 'new';
  bool get isReplied => status == 'replied';
  bool get isClosed => status == 'closed';

  String get typeDisplayName {
    switch (type) {
      case 'inquiry':
        return 'Pertanyaan';
      case 'report':
        return 'Laporan';
      default:
        return type;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'new':
        return 'Baru';
      case 'replied':
        return 'Sudah Dibalas';
      case 'closed':
        return 'Ditutup';
      default:
        return status;
    }
  }
}

class ContactReply {
  final int id;
  final int contactId;
  final int adminId;
  final String reply;
  final String createdAt;
  final String? adminName;

  ContactReply({
    required this.id,
    required this.contactId,
    required this.adminId,
    required this.reply,
    required this.createdAt,
    this.adminName,
  });

  factory ContactReply.fromJson(Map<String, dynamic> json) {
    return ContactReply(
      id: json['id'] ?? 0,
      contactId: json['contact_id'] ?? 0,
      adminId: json['admin_id'] ?? 0,
      reply: json['reply'] ?? '',
      createdAt: json['created_at'] ?? '',
      adminName: json['admin_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contact_id': contactId,
      'admin_id': adminId,
      'reply': reply,
      'created_at': createdAt,
      if (adminName != null) 'admin_name': adminName,
    };
  }
}

class ContactStats {
  final int totalContacts;
  final int totalInquiries;
  final int totalReports;
  final int newContacts;
  final int repliedContacts;
  final int closedContacts;
  final List<Contact> recentContacts;

  ContactStats({
    required this.totalContacts,
    required this.totalInquiries,
    required this.totalReports,
    required this.newContacts,
    required this.repliedContacts,
    required this.closedContacts,
    required this.recentContacts,
  });

  factory ContactStats.fromJson(Map<String, dynamic> json) {
    return ContactStats(
      totalContacts: json['total_contacts'] ?? 0,
      totalInquiries: json['total_inquiries'] ?? 0,
      totalReports: json['total_reports'] ?? 0,
      newContacts: json['new_contacts'] ?? 0,
      repliedContacts: json['replied_contacts'] ?? 0,
      closedContacts: json['closed_contacts'] ?? 0,
      recentContacts: json['recent_contacts'] != null
          ? (json['recent_contacts'] as List)
              .map((contact) => Contact.fromJson(contact))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_contacts': totalContacts,
      'total_inquiries': totalInquiries,
      'total_reports': totalReports,
      'new_contacts': newContacts,
      'replied_contacts': repliedContacts,
      'closed_contacts': closedContacts,
      'recent_contacts': recentContacts.map((c) => c.toJson()).toList(),
    };
  }
}

class SubmitContactRequest {
  final String name;
  final String email;
  final String subject;
  final String message;
  final String type;
  final int? userId;

  SubmitContactRequest({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.type,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      'type': type,
      if (userId != null) 'user_id': userId,
    };
  }

  // Validation methods
  String? validateName() {
    if (name.trim().isEmpty) return 'Nama tidak boleh kosong';
    if (name.length > 191) return 'Nama terlalu panjang (max 191 karakter)';
    return null;
  }

  String? validateEmail() {
    if (email.trim().isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validateSubject() {
    if (subject.trim().isEmpty) return 'Subjek tidak boleh kosong';
    if (subject.length > 191)
      return 'Subjek terlalu panjang (max 191 karakter)';
    return null;
  }

  String? validateMessage() {
    if (message.trim().isEmpty) return 'Pesan tidak boleh kosong';
    if (message.trim().length < 3) return 'Pesan minimal 3 karakter';
    return null;
  }

  String? validateType() {
    if (!['inquiry', 'report'].contains(type)) {
      return 'Tipe tidak valid';
    }
    return null;
  }

  Map<String, String?> validateAll() {
    return {
      'name': validateName(),
      'email': validateEmail(),
      'subject': validateSubject(),
      'message': validateMessage(),
      'type': validateType(),
    };
  }

  bool get isValid {
    final errors = validateAll();
    return errors.values.every((error) => error == null);
  }
}
