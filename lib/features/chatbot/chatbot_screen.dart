import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../common/widgets/app_bar.dart';
import './models/chat_message.dart';
import './models/chat_suggestion.dart';
import './widgets/chat_bubble.dart';
import './widgets/chat_input.dart';
import './widgets/chat_suggestions.dart';
import '../../rag_pipeline/pipeline/rag_pipeline.dart';
import '../../rag_pipeline/llm/llm_services.dart';
import '../../core/database/database_service.dart';
import 'dart:async';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final RAGPipeline _ragPipeline;
  int? _conversationId;
  bool _isTyping = false;
  String _userName = 'Alex'; // Default fallback

  final List<ChatSuggestion> _suggestions = [
    ChatSuggestion(text: 'Cheapest gas stations near me', icon: Icons.local_gas_station_outlined),
    ChatSuggestion(text: 'Current fuel price in Baguio', icon: Icons.explore_outlined),
    ChatSuggestion(text: 'How to improve my efficiency score?', icon: Icons.eco_outlined),
    ChatSuggestion(text: 'Estimate fuel for 100km', icon: Icons.calculate_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // 1. Initialize RAG Pipeline
    _ragPipeline = RAGPipeline(llm: LLMServiceFactory.getService());
    _conversationId = await _ragPipeline.createNewConversation('Chat with Agila');

    // 2. Fetch User Profile for personalized greeting
    final onboardingData = await DatabaseService().getOnboardingData();
    if (onboardingData != null) {
      setState(() {
        _userName = onboardingData['user_name'] ?? 'Alex';
      });
    }

    // 3. Start with a greeting from AI
    setState(() {
      _messages.add(ChatMessage(
        text: "Hello $_userName! I'm Agila, your travel assistant. I'm already familiar with your ${_userName == 'Alex' ? 'vehicle' : onboardingData?['vehicle_type'] ?? 'vehicle'}. How can I help you today?",
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage([String? text]) async {
    final messageText = text ?? _controller.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: messageText,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      ));
      if (text == null) _controller.clear();
    });

    _scrollToBottom();

    setState(() {
      _isTyping = true;
    });

    // 2. Process query through RAG Pipeline
    try {
      final response = await _ragPipeline.processQuery(_conversationId!, messageText);
      
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: response,
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: "I'm having some trouble connecting to my knowledge base. Please try again in a moment.",
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      appBar: const CommonAppBar(
        title: 'Agila AI',
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) => ChatBubble(message: _messages[index]),
            ),
          ),
          if (_messages.length < 2) // Only show suggestions before the user's first message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ChatSuggestions(
                suggestions: _suggestions,
                onSuggestionTap: _sendMessage,
              ),
            ),
          ChatInput(
            controller: _controller,
            onSend: () => _sendMessage(),
          ),
        ],
      ),
    );
  }
}
