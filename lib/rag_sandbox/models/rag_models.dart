class Conversation {
  final int? id;
  final String title;
  final DateTime createdAt;

  Conversation({
    this.id,
    required this.title,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      title: map['title'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class Message {
  final int? id;
  final int conversationId;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime createdAt;

  Message({
    this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      conversationId: map['conversation_id'],
      role: map['role'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class Embedding {
  final int? id;
  final int messageId;
  final List<double> vector;

  Embedding({
    this.id,
    required this.messageId,
    required this.vector,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message_id': messageId,
      'vector': vector.join(','),
    };
  }

  factory Embedding.fromMap(Map<String, dynamic> map) {
    return Embedding(
      id: map['id'],
      messageId: map['message_id'],
      vector: (map['vector'] as String).split(',').map((e) => double.parse(e)).toList(),
    );
  }
}
