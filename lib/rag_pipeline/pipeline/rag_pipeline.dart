import '../database/database_helper.dart';
import '../models/rag_models.dart';
import '../embeddings/embedding_service.dart';
import '../llm/llm_interface.dart';
import 'retrieval_system.dart';

class RAGPipeline {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final EmbeddingService _embeddingService = EmbeddingService();
  final RetrievalSystem _retrievalSystem = RetrievalSystem();
  final LLMInterface _llm;

  RAGPipeline({required LLMInterface llm}) : _llm = llm;

  Future<String> processQuery(int conversationId, String userQuery) async {
    // 1. Save User Message
    final userMessage = Message(
      conversationId: conversationId,
      role: 'user',
      content: userQuery,
      createdAt: DateTime.now(),
    );
    final userMessageId = await _dbHelper.insertMessage(userMessage);

    // 2. Generate and Save Embedding for User Message
    final userVector = await _embeddingService.generateEmbedding(userQuery);
    await _dbHelper.insertEmbedding(Embedding(
      messageId: userMessageId,
      vector: userVector,
    ));

    // 3. Retrieve Context
    final contextResults = await _retrievalSystem.retrieveContext(userQuery);
    final contextString = _retrievalSystem.formatContextForLLM(contextResults);

    // 4. Generate LLM Response with Context
    final systemPrompt = "You are a helpful AI assistant. Use the following context from previous interactions to help answer the user query.\n\n$contextString";
    final assistantResponse = await _llm.generateResponse(userQuery, systemContext: systemPrompt);

    // 5. Save Assistant Message
    final assistantMessage = Message(
      conversationId: conversationId,
      role: 'assistant',
      content: assistantResponse,
      createdAt: DateTime.now(),
    );
    final assistantMessageId = await _dbHelper.insertMessage(assistantMessage);

    // 6. Generate and Save Embedding for Assistant Message (to build future context)
    final assistantVector = await _embeddingService.generateEmbedding(assistantResponse);
    await _dbHelper.insertEmbedding(Embedding(
      messageId: assistantMessageId,
      vector: assistantVector,
    ));

    return assistantResponse;
  }

  Future<int> createNewConversation(String title) async {
    return await _dbHelper.insertConversation(Conversation(
      title: title,
      createdAt: DateTime.now(),
    ));
  }
  
  Future<List<Message>> getChatHistory(int conversationId) async {
    return await _dbHelper.getMessages(conversationId);
  }
}
