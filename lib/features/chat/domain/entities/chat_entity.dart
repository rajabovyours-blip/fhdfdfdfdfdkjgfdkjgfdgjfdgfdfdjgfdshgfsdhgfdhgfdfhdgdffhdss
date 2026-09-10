class ChatSessionEntity {
  final String id;
  final String name;
  final String phone;
  final bool isResolved;

  ChatSessionEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.isResolved,
  });

  factory ChatSessionEntity.fromJson(Map<String, dynamic> json) {
    return ChatSessionEntity(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      isResolved: json['is_resolved'] ?? false,
    );
  }
}

class ChatMessageEntity {
  final String id;
  final String sessionId;
  final String sender;
  final String text;
  final DateTime createdAt;

  ChatMessageEntity({
    required this.id,
    required this.sessionId,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessageEntity.fromJson(Map<String, dynamic> json) {
    return ChatMessageEntity(
      id: json['id'],
      sessionId: json['session_id'],
      sender: json['sender'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}
