import 'package:google_generative_ai/google_generative_ai.dart';
import 'llm_interface.dart';

class GeminiLLMService implements LLMInterface {
  final String apiKey;
  late final GenerativeModel model;

  GeminiLLMService({required this.apiKey}) {
    model = GenerativeModel(
      model: 'gemini-3.1-flash-lite-preview',
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
