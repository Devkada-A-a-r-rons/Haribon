# 🏗️ RAG Pipeline Module Instructions (Hybrid Flutter)

This module provides a local-first Retrieval Augmented Generation (RAG) pipeline with hybrid switching between **Native LLM** (for local/desktop) and **Gemini AI** (for web/cloud).

## A. System Overview

The RAG pipeline follows a standard embedding-retrieval-generation flow:

1.  **Ingestion**: User input is saved to SQLite.
2.  **Embedding**: A simulated embedding is generated for the input.
3.  **Retrieval**: The system searches the local database for messages with similar embeddings using Cosine Similarity.
4.  **Augmentation**: Top relevant context is formatted into a system prompt.
5.  **Generation**: The augmented prompt is sent to the **LLM** (Gemini or Local Qwen).
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
[LLM Service (Factory Switched)]
     ↓
[Save Assistant Response] → [Generate Embedding]
```

## B. Hybrid LLM Setup

This system uses `LLMServiceFactory` to determine which LLM to use based on the platform.

### 1. Web Implementation (Gemini)
When running on the web (`kIsWeb`), the system automatically switches to the **Gemini AI API**.
*   **Package**: `google_generative_ai`
*   **Model**: `gemini-1.5-flash`
*   **Config**: Uses `GEMINI_API_KEY` from environment variables.

### 2. Local/Desktop Implementation (Native/Local)
When running on local devices, it can use either:
*   **NativeLLMService**: Uses `llama_cpp_dart` to run Qwen2.5 3B natively.
*   **LocalLLMService**: Connects to a local server (e.g., Ollama or custom FastAPI) at `localhost:8000`.

### 3. Usage
```dart
// The factory handles platform detection automatically
final llm = LLMServiceFactory.getService();
final rag = RAGPipeline(llm: llm);
```

### 4. Running the Example
To verify the integration:
```bash
dart lib/rag_pipeline/example_usage.dart
```

## C. Folder Structure

```text
/lib/rag_pipeline/
├── database/         # SQLite persistence layer
├── models/           # Data structures
├── embeddings/       # Embedding logic & similarity math
├── llm/              # Gemini, Native, & Local LLM implementations
├── pipeline/         # Orchestration logic (The RAG "Brain")
└── instruction.md    # This file
```

---
*Developed by Antigravity AI*
