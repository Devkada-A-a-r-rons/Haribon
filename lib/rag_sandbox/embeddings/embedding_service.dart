import 'dart:math';

class EmbeddingService {
  static const int vectorDimensions = 384; // Typical for small sentence transformers

  /// Simulates generating an embedding for a given text.
  /// In a real scenario, this would call a local model via TFLite/FFI or a remote API.
  Future<List<double>> generateEmbedding(String text) async {
    // Artificial delay to simulate processing
    await Future.delayed(const Duration(milliseconds: 100));

    // For simulation, we create a deterministic vector based on the text hash
    // This allows same text to have same "embedding"
    final seed = text.hashCode;
    final random = Random(seed);
    
    return List.generate(vectorDimensions, (_) => random.nextDouble() * 2 - 1);
  }

  /// Calculates cosine similarity between two vectors.
  double calculateSimilarity(List<double> v1, List<double> v2) {
    if (v1.length != v2.length) return 0.0;
    
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (int i = 0; i < v1.length; i++) {
      dotProduct += v1[i] * v2[i];
      normA += v1[i] * v1[i];
      normB += v2[i] * v2[i];
    }
    
    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}
