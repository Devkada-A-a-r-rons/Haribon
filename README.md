# 🦅 Haribon: Smart Road Assistant

> **“Plan every kilometer—fuel, cost, stops, and impact.”**

Haribon is a production-grade, offline-first roadtrip assistant built with Flutter. It combines real-world vehicle efficiency data with cutting-edge AI to help travelers optimize their journeys for cost, time, and environmental sustainability.

---

## 🚀 Key Features

### 🗺️ Smart Trip Planner
Orchestrate your route with precision. Haribon calculates the most efficient paths, predicts fuel consumption based on your specific vehicle model, and suggests optimal refueling stops.

### 🤖 Hybrid RAG AI Pipeline
A sophisticated AI assistant that "remembers" your vehicle and trip history.
- **Web**: Powered by **Gemini 3.1 Flash Lite** for high-speed cloud reasoning.
- **Local/Native**: Powered by **Qwen2.5 3B** running natively on-device for total privacy.
- **Context-Aware**: Uses Retrieval Augmented Generation (RAG) to provide answers based on your unique data.

### 📊 Vehicle Intelligence
Deep-dive into your vehicle's performance. Compare efficiency across different models using our curated dataset of over 3,000 vehicles.

### 📈 Journey Summary & Timeline
Get a visual breakdown of your trip.
- **Efficiency Score**: A proprietary metric tracking your fuel optimization.
- **Route Breakdown**: Detailed charts showing city vs. highway performance.
- **Interactive Timeline**: Every stop, insight, and event logged in a sleek, modern UI.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform Mobile/Web/Desktop)
- **Intelligence**: 
  - [Google Generative AI](https://ai.google.dev/) (Gemini API)
  - [llama_cpp_dart](https://pub.dev/packages/llama_cpp_dart) (Native LLM Inference)
- **Data & Storage**: 
  - [SQFlite](https://pub.dev/packages/sqflite) (Local persistence)
  - [Supabase](https://supabase.com/) (Cloud sync integration)
- **Visualization**: 
  - [Flutter Map](https://pub.dev/packages/flutter_map) (OpenStreetMap)
  - [Syncfusion Charts](https://www.syncfusion.com/flutter-widgets) (Data visualization)

---

## 🏗️ Architecture: RAG Pipeline

Haribon features a state-of-the-art hybrid RAG pipeline:
1. **Ingestion**: Trip logs and vehicle data are indexed in a local vector-ready database.
2. **Retrieval**: When you ask a question, the system retrieves relevant historical context.
3. **Augmentation**: The LLM prompt is enriched with this context.
4. **Generation**: The assistant provides a highly personalized response.

---

## 👥 Development Team

This project is maintained by **Devkada**:

- **Arron Kian Parejas** – AI/ML Specialist and Full-Stack Engineer
- **Aaron Matthew Francisco** – Frontend Engineer and UI/UX Designer
- **Adrian Kyle Mariano** – Frontend & UI/UX Designer
- **Laur Francisco** – UI/UX Designer and Video Editor

---

## 🏁 Getting Started

### Prerequisites
- Flutter SDK (^3.11.5)
- Gemini API Key (saved in `.env`)

### Installation
1. Clone the repository
2. Create a `.env` file in the root directory
3. Add your keys: `GEMINI_API_KEY=your_key_here`
4. Run the app:
   ```bash
   flutter pub get
   flutter run
   ```

---
*Built with ❤️ for the future of smart mobility.*
