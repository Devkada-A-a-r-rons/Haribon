import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../theme/app_colors.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isAi = message.sender == MessageSender.ai;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAi) _buildAiAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAi ? AppColors.containerLowest : AppColors.blueAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isAi ? 4 : 20),
                      bottomRight: Radius.circular(isAi ? 20 : 4),
                    ),
                    boxShadow: isAi ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ] : null,
                  ),
                  child: MarkdownBody(
                    data: message.text,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.poppins(
                        fontSize: 15,
                        height: 1.4,
                        color: isAi ? AppColors.textPrimary : Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      strong: GoogleFonts.poppins(
                        fontSize: 15,
                        height: 1.4,
                        color: isAi ? AppColors.textPrimary : Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      listBullet: GoogleFonts.poppins(
                        fontSize: 15,
                        color: isAi ? AppColors.textPrimary : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('h:mm a').format(message.timestamp),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!isAi) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.blueAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.container,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 20),
    );
  }
}

