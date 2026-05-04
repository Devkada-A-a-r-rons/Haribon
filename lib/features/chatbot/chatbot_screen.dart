import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../common/widgets/app_bar.dart';
import './models/chat_message.dart';
import './models/chat_suggestion.dart';
import './widgets/chat_bubble.dart';
import './widgets/chat_input.dart';
import './widgets/chat_suggestions.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatSuggestion> _suggestions = [
    ChatSuggestion(text: 'Cheapest gas stations near me', icon: Icons.local_gas_station_outlined),
    ChatSuggestion(text: 'Current fuel price in Baguio', icon: Icons.explore_outlined),
    ChatSuggestion(text: 'How to improve my efficiency score?', icon: Icons.eco_outlined),
    ChatSuggestion(text: 'Estimate fuel for 100km', icon: Icons.calculate_outlined),
  ];

  @override
  void initState() {
    super.initState();
    // Start with a greeting from AI
    _messages.add(ChatMessage(
      text: "Hello Alex! I can help you find the best gas prices, calculate your vehicle's fuel consumption, or optimize your route. What's on your mind?",
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    ));
  }

  void _sendMessage([String? text]) {
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

    // Mock AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: "Searching... Based on your route, the Petron station at NLEX Kilometer 23 currently offers Xtra Advance at ₱58.45/L, which is the lowest price for the next 50km.",
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
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
