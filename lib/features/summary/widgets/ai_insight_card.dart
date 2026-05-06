import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../common/widgets/typing_text.dart';

/// MODULE: AI PRO INSIGHT CARD
class AiInsightCard extends StatelessWidget {
  final String insight;

  const AiInsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
   
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -15,
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 100,
              color: AppColors.primaryMain.withValues(alpha: 0.6),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading AI Icon without a background
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.psychology_outlined,
                    color: AppColors.primaryDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'AI PRO INSIGHT',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Insight body text
                      insight.isEmpty 
                        ? const ThinkingIndicator()
                        : TypingText(
                            text: insight,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
