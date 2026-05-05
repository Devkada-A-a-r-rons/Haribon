import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/rag_models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // Web mock storage
  int _mockIdCounter = 1;
  final List<Conversation> _webConversations = [];
  final List<Message> _webMessages = [];
  final List<Embedding> _webEmbeddings = [];

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('sqflite is not supported on web');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) throw UnsupportedError('Web not supported');
    String path = join(await getDatabasesPath(), 'rag_sandbox.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id INTEGER,
        role TEXT,
        content TEXT,
        created_at TEXT,
        FOREIGN KEY (conversation_id) REFERENCES conversations (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE embeddings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message_id INTEGER,
        vector TEXT,
        FOREIGN KEY (message_id) REFERENCES messages (id)
      )
    ''');
  }

  // Conversation CRUD
  Future<int> insertConversation(Conversation conversation) async {
    if (kIsWeb) {
      final newConv = Conversation(id: _mockIdCounter++, title: conversation.title, createdAt: conversation.createdAt);
      _webConversations.add(newConv);
      return newConv.id!;
    }
    Database db = await database;
    return await db.insert('conversations', conversation.toMap());
  }

  Future<List<Conversation>> getConversations() async {
    if (kIsWeb) return List.from(_webConversations);
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('conversations');
    return List.generate(maps.length, (i) => Conversation.fromMap(maps[i]));
  }

  // Message CRUD
  Future<int> insertMessage(Message message) async {
    if (kIsWeb) {
      final newMessage = Message(id: _mockIdCounter++, conversationId: message.conversationId, role: message.role, content: message.content, createdAt: message.createdAt);
      _webMessages.add(newMessage);
      return newMessage.id!;
    }
    Database db = await database;
    return await db.insert('messages', message.toMap());
  }

  Future<List<Message>> getMessages(int conversationId) async {
    if (kIsWeb) {
      return _webMessages.where((m) => m.conversationId == conversationId).toList();
    }
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => Message.fromMap(maps[i]));
  }

  // Embedding CRUD
  Future<int> insertEmbedding(Embedding embedding) async {
    if (kIsWeb) {
      final newEmb = Embedding(id: _mockIdCounter++, messageId: embedding.messageId, vector: embedding.vector);
      _webEmbeddings.add(newEmb);
      return newEmb.id!;
    }
    Database db = await database;
    return await db.insert('embeddings', embedding.toMap());
  }

  Future<List<Map<String, dynamic>>> getAllEmbeddingsWithContent() async {
    if (kIsWeb) {
      return _webEmbeddings.map((e) {
        final m = _webMessages.firstWhere((m) => m.id == e.messageId);
        return {
          'vector': e.vector,
          'content': m.content,
          'role': m.role,
          'message_id': m.id,
        };
      }).toList();
    }
    Database db = await database;
    return await db.rawQuery('''
      SELECT e.vector, m.content, m.role, m.id as message_id
      FROM embeddings e
      JOIN messages m ON e.message_id = m.id
    ''');
  }
}
