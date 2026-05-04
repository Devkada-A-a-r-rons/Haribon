import 'dart:io';
import 'package:path/path.dart' as p;
import 'pipeline/rag_pipeline.dart';
import 'llm/llm_services.dart';

/// This is a simple example of how to use the RAG Pipeline with Factory switching.
void main() async {
  print('📚 Initializing RAG Pipeline...');

  // 1. Initialize LLM via Factory (automatically switches to Gemini on Web)
  // On local, it defaults to LocalLLMService (expected at localhost:8000)
  // You can pass an API key here or via --dart-define=GEMINI_API_KEY=xxx
  final llm = LLMServiceFactory.getService();
  
  // 2. Initialize Pipeline
  final rag = RAGPipeline(llm: llm);

  // 3. Create a conversation
  final conversationId = await rag.createNewConversation('RAG Pipeline Test');

  // 4. Send a query
  print('\n--- User: Tell me about the Haribon project ---');
  final response1 = await rag.processQuery(conversationId, 'Tell me about the Haribon project');
  print('--- AI: $response1 ---');

  print('\n✅ RAG Process completed!');
}
