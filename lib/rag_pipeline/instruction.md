# 🏗️ RAG Sandbox Module Instructions (Full Flutter)

This module provides a local-first Retrieval Augmented Generation (RAG) pipeline running **natively inside your Flutter application** using Dart FFI.

## A. System Overview

The RAG pipeline follows a standard embedding-retrieval-generation flow:

1.  **Ingestion**: User input is saved to SQLite.
2.  **Embedding**: A simulated embedding is generated for the input.
3.  **Retrieval**: The system searches the local database for messages with similar embeddings using Cosine Similarity.
4.  **Augmentation**: Top relevant context is formatted into a system prompt.
5.  **Generation**: The augmented prompt is sent to the **Native Qwen LLM**.
6.  **Storage**: The response is saved and embedded, building the "memory" of the system.

### Data Flow Diagram
```text
[User Query] 
     ↓
[Store in DB] → [Generate Embedding] → [Save Embedding]
     ↓
[Search DB Embeddings] ← (Cosine Similarity)
     ↓
[Retrieve Context]
     ↓
[Format System Prompt] (Context + Query)
     ↓
[Native Qwen LLM (Dart FFI)]
     ↓
[Save Assistant Response] → [Generate Embedding]
```

## B. Native Flutter LLM Setup

This sandbox runs the **Qwen2.5 3B** model **natively inside the Flutter process** using Dart FFI.

### 1. Requirements
*   **Model File**: The `.gguf` file is located at `lib/rag_sandbox/models/`.
*   **Dependencies**: Uses `llama_cpp_dart` and `path_provider`.

### 2. Implementation
The `NativeLLMService` in `lib/rag_sandbox/llm/native_llm_service.dart` handles the heavy lifting:
*   Loads the `.gguf` file using FFI.
*   Offloads inference to background isolates.
*   Leverages GPU (Metal) on Mac devices for fast performance.

### 3. Usage
```dart
final modelPath = 'lib/rag_sandbox/models/qwen2.5-3b-instruct-q4_k_m.gguf';
final llm = NativeLLMService(modelPath: modelPath);
final rag = RAGPipeline(llm: llm);
```

### 4. Running the Example
To verify the full native integration:
```bash
dart lib/rag_sandbox/example_usage.dart
```

## C. Future Upgrade Plan

*   **Database**: Replace `DatabaseHelper` (SQLite) with `supabase_flutter`.
*   **Vector Search**: Upgrade to Supabase's `pgvector`.
*   **Embeddings**: Replace the mock `EmbeddingService` with a real TFLite model or remote API.
*   **LLM Routing**: Switch to Gemini API using `google_generative_ai` for cloud fallback.

## D. Folder Structure

```text
/lib/rag_sandbox/
├── database/         # SQLite persistence layer
├── models/           # Data structures & .gguf model file
├── embeddings/       # Embedding logic & similarity math
├── llm/              # Native & Mock LLM implementations
├── pipeline/         # Orchestration logic (The RAG "Brain")
└── instruction.md    # This file
```

---
*Developed by Antigravity AI*
