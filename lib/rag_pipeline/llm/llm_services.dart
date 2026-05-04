import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'llm_interface.dart';

class LLMServiceFactory {
  static LLMInterface getService({String? apiKey}) {
    if (kIsWeb) {
      return GeminiLLMService(apiKey: apiKey ?? const String.fromEnvironment('GEMINI_API_KEY'));
    } else {
      return LocalLLMService();
    }
  }
}

class GeminiLLMService implements LLMInterface {
  final String apiKey;
  late final GenerativeModel model;

  GeminiLLMService({required this.apiKey}) {
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  @override
  Future<String> generateResponse(String prompt, {String? systemContext}) async {
    try {
      final content = [
        if (systemContext != null) Content.text('System Context: $systemContext'),
        Content.text(prompt),
      ];
      
      final response = await model.generateContent(content);
      return response.text ?? 'No response from Gemini';
    } catch (e) {
      return 'Error connecting to Gemini: $e';
    }
  }
}

class LocalLLMService implements LLMInterface {
  final String baseUrl; // e.g., http://localhost:8000

  LocalLLMService({this.baseUrl = 'http://localhost:8000'});

  @override
  Future<String> generateResponse(String prompt, {String? systemContext}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/chat/completions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            if (systemContext != null) {'role': 'system', 'content': systemContext},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 512,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'No response content';
      } else {
        throw Exception('Failed to connect to local LLM server: ${response.statusCode}');
      }
    } catch (e) {
      return 'Error connecting to Local LLM: $e. \nMake sure the local server is running at $baseUrl. \nRun: python3 rag_pipeline/scripts/run_server.py';
    }
  }
}

class MockLLMService implements LLMInterface {
  @override
  Future<String> generateResponse(String prompt, {String? systemContext}) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (systemContext != null && systemContext.contains('context')) {
      return "Based on the provided context, I can tell you that the RAG pipeline is working. [MOCK RESPONSE]";
    }
    
    return "This is a mock response from the RAG Pipeline. To get real answers, connect a local Qwen2.5 instance via llama.cpp or use Gemini on Web.";
  }
}
