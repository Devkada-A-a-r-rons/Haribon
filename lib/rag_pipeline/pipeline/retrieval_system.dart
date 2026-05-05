import '../database/database_helper.dart';
import '../embeddings/embedding_service.dart';

class RetrievalSystem {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final EmbeddingService _embeddingService = EmbeddingService();

  Future<List<Map<String, dynamic>>> retrieveContext(String query, {int topK = 3}) async {
    // 1. Generate embedding for the query
    final queryVector = await _embeddingService.generateEmbedding(query);

    // 2. Fetch all embeddings from DB
    final allEmbeddings = await _dbHelper.getAllEmbeddingsWithContent();

    if (allEmbeddings.isEmpty) return [];

    // 3. Calculate similarity and rank
    List<Map<String, dynamic>> results = [];
    for (var entry in allEmbeddings) {
      List<double> vector;
      final rawVector = entry['vector'];
      
      if (rawVector is String) {
        vector = rawVector.split(',').map((e) => double.parse(e)).toList();
      } else if (rawVector is List) {
        vector = (rawVector as List).map((e) => (e as num).toDouble()).toList();
      } else {
        continue;
      }
      
      final similarity = _embeddingService.calculateSimilarity(queryVector, vector);
      
      results.add({
        'content': entry['content'],
        'role': entry['role'],
        'similarity': similarity,
        'message_id': entry['message_id'],
      });
    }

    // Sort by similarity descending
    results.sort((a, b) => (b['similarity'] as double).compareTo(a['similarity'] as double));

    // Return top K
    return results.take(topK).toList();
  }

  String formatContextForLLM(List<Map<String, dynamic>> contextResults) {
    if (contextResults.isEmpty) return "No relevant history found.";

    StringBuffer buffer = StringBuffer("Relevant previous context:\n");
    for (var res in contextResults) {
      buffer.writeln("- [${res['role']}]: ${res['content']}");
    }
    return buffer.toString();
  }
}
