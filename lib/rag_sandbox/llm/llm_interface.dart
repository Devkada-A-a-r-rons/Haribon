abstract class LLMInterface {
  Future<String> generateResponse(String prompt, {String? systemContext});
}
