import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../models/chat_suggestion.dart';

class ChatSuggestions extends StatelessWidget {
  final List<ChatSuggestion> suggestions;
  final Function(String) onSuggestionTap;

  const ChatSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: suggestions.map((suggestion) => _buildSuggestionItem(suggestion)).toList(),
    );
  }

  Widget _buildSuggestionItem(ChatSuggestion suggestion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onSuggestionTap(suggestion.text),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.blueGreyLightestBg, // Light blue background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(suggestion.icon, size: 18, color: AppColors.blueAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion.text,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

