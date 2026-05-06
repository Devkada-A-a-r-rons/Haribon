import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/database_helper.dart';
import '../../core/database/database_service.dart';
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

    // 3.5 Fetch User Profile Context
    final supabase = Supabase.instance.client;
    final onboardingData = await DatabaseService().getOnboardingData();
    
    // Fetch Active Plan
    final activePlan = await supabase
        .from('vehicle_configurations')
        .select()
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    // Fetch Recent History
    final recentHistory = await supabase
        .from('smart_trips')
        .select()
        .order('created_at', ascending: false)
        .limit(3);

    String userContext = "\n\n--- CURRENT USER CONTEXT ---";
    if (onboardingData != null) {
      userContext += "\nUser Profile:\n"
          "- Name: ${onboardingData['user_name']}\n"
          "- Vehicle: ${onboardingData['vehicle_type']}\n"
          "- Travel Frequency: ${onboardingData['travel_frequency']}\n"
          "- Avg Refueling Cost: ₱${onboardingData['avg_refueling_cost']}\n"
          "- Planning Style: ${onboardingData['planning_style']}\n"
          "- Refueling Priority: ${onboardingData['refueling_priority']}";
    }

    if (activePlan != null) {
      userContext += "\n\nCurrent Active Journey:\n"
          "- Origin: ${activePlan['origin_name']}\n"
          "- Destination: ${activePlan['destination_name']}\n"
          "- Planned Budget: ₱${activePlan['budget']}\n"
          "- Vehicle: ${activePlan['vehicle_brand']} ${activePlan['vehicle_model']}\n"
          "- Distance: ${activePlan['route_distance_km'] ?? 'Unknown'} km";
    }

    if (recentHistory != null && (recentHistory as List).isNotEmpty) {
      userContext += "\n\nRecent Trip History:";
      for (var trip in recentHistory) {
        userContext += "\n- ${trip['origin_name']} to ${trip['destination_name']}: "
            "${trip['distance_km']}km, ₱${trip['est_fuel_cost']} fuel, Score: ${trip['efficiency_score']}/100";
      }
    }
    userContext += "\n--- END CONTEXT ---\n";

    // 3. Retrieve Context
    final contextResults = await _retrievalSystem.retrieveContext(userQuery);
    final contextString = _retrievalSystem.formatContextForLLM(contextResults);

    // 4. Generate LLM Response with Context
    final systemPrompt = "You are Haribon, a helpful AI travel assistant for the Haribon app. "
        "Use the following context and user profile to help answer the user query.$userContext\n\nContext from previous interactions:\n$contextString";
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
