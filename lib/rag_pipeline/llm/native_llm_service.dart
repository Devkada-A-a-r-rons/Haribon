import 'dart:io';
import 'dart:async';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'llm_interface.dart';

class NativeLLMService implements LLMInterface {
  final String modelPath;
  LlamaParent? _llama;
  bool _isInitialized = false;

  NativeLLMService({required this.modelPath});

  Future<void> init() async {
    if (_isInitialized) return;

    if (!File(modelPath).existsSync()) {
      throw Exception("Model file not found at $modelPath. Please run the download script first.");
    }

    // Initialize the engine with reasonable defaults for a 3B model
    final loadCommand = LlamaLoad(
      path: modelPath,
      modelParams: ModelParams(),
      contextParams: ContextParams()..nCtx = 2048,
      samplingParams: SamplerParams()..temp = 0.7,
    );

    _llama = LlamaParent(loadCommand);
    await _llama!.init();
    _isInitialized = true;
  }

  @override
  Future<String> generateResponse(String prompt, {String? systemContext}) async {
    if (!_isInitialized) {
      await init();
    }

    final fullPrompt = _formatPrompt(prompt, systemContext);
    
    StringBuffer responseBuffer = StringBuffer();
    final completer = Completer<String>();
    
    StreamSubscription? subscription;
    subscription = _llama!.stream.listen((response) {
      if (response is String) {
        responseBuffer.write(response);
      }
    }, onDone: () {
      if (!completer.isCompleted) {
        completer.complete(responseBuffer.toString().trim());
      }
      subscription?.cancel();
    }, onError: (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
      subscription?.cancel();
    });

    _llama!.sendPrompt(fullPrompt);
    
    // Safety timeout for local inference
    return completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () => responseBuffer.toString().trim(),
    );
  }

  String _formatPrompt(String prompt, String? context) {
    // ChatML format for Qwen2.5
    String system = context ?? "You are a helpful assistant.";
    return "<|im_start|>system\n$system<|im_end|>\n<|im_start|>user\n$prompt<|im_end|>\n<|im_start|>assistant\n";
  }

  void dispose() {
    _llama?.dispose();
  }
}