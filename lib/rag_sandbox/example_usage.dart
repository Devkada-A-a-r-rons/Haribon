import 'dart:io';
import 'package:path/path.dart' as p;
import 'pipeline/rag_pipeline.dart';
import 'llm/native_llm_service.dart';

/// This is a simple example of how to use the RAG Sandbox with Native LLM.
void main() async {
  // 1. Path to the model downloaded via python script
  // In a real app, you might bundle this or download it to app documents
  final modelPath = p.join(Directory.current.path, 'lib', 'rag_sandbox', 'models', 'qwen2.5-3b-instruct-q4_k_m.gguf');
  
  print('📚 Loading Native Model from: $modelPath');

  // 2. Initialize Native LLM
  final llm = NativeLLMService(modelPath: modelPath);
  
  // 3. Initialize Pipeline
  final rag = RAGPipeline(llm: llm);

  // 4. Create a conversation
  final conversationId = await rag.createNewConversation('Native RAG Test');

  // 5. Send a query
  print('\n--- User: Tell me about the Haribon project ---');
  final response1 = await rag.processQuery(conversationId, 'Tell me about the Haribon project');
  print('--- AI: $response1 ---');

  print('\n✅ RAG Process completed natively!');
}
