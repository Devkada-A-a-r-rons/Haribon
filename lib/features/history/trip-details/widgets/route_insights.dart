import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../theme/app_colors.dart';
import '../../../../rag_pipeline/llm/gemini_llm_service.dart';

class RouteInsights extends StatefulWidget {
  final Map<String, dynamic> tripData;
  const RouteInsights({super.key, required this.tripData});

  @override
  State<RouteInsights> createState() => _RouteInsightsState();
}

class _RouteInsightsState extends State<RouteInsights> {
  List<dynamic> _insights = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    // 1. Check if insights already exist in tripData
    final existing = widget.tripData['ai_insights'];
    if (existing != null && existing is List && existing.isNotEmpty) {
      setState(() {
        _insights = existing;
      });
      return;
    }

    // 2. Generate if not present
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Gemini API Key missing');
      }

      final gemini = GeminiLLMService(apiKey: apiKey);
      
      final origin = widget.tripData['origin_name'] ?? 'Unknown';
      final dest = widget.tripData['destination_name'] ?? 'Unknown';
      final dist = (widget.tripData['distance_km'] ?? widget.tripData['route_distance_km'] ?? 0).toStringAsFixed(1);
      final cost = (widget.tripData['est_fuel_cost'] ?? 0.0).toStringAsFixed(0);

      final prompt = """
      Generate exactly 3 short, actionable, and interesting travel insights for a road trip from $origin to $dest ($dist km, estimated fuel cost â‚±$cost).
      
      Format the response as a JSON array of objects. Each object must have:
      - "title": A short catchy title (max 4 words).
      - "description": A 1-sentence insight or optimization tip (max 20 words).
      - "type": One of ["savings", "terrain", "tip", "eco"].
      
      Example:
      [
        {"title": "Drafting Win", "description": "You saved 0.4L by maintaining steady highway distance behind larger vehicles.", "type": "savings"},
        {"title": "Mountain Climb", "description": "Expect 15% higher fuel use during the 5km steep ascent near Baguio.", "type": "terrain"},
        {"title": "Eco Mode", "description": "Maintaining 80km/h on this stretch can reduce emissions by 12%.", "type": "eco"}
      ]
      
      Return ONLY the JSON array.
      """;

      final response = await gemini.generateResponse(prompt);
      
      // Check if response is an error message
      if (response.startsWith('Error') || response.contains('Error connecting')) {
        throw Exception(response);
      }
      
      // Clean up response if it has markdown code blocks
      String jsonStr = response.trim();
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.substring(7, jsonStr.length - 3).trim();
      } else if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.substring(3, jsonStr.length - 3).trim();
      }

      // Final sanitization: ensure it looks like a JSON array
      if (!jsonStr.startsWith('[')) {
        final startIndex = jsonStr.indexOf('[');
        final endIndex = jsonStr.lastIndexOf(']');
        if (startIndex != -1 && endIndex != -1) {
          jsonStr = jsonStr.substring(startIndex, endIndex + 1);
        } else {
          throw const FormatException('AI response did not contain a valid JSON array');
        }
      }

      final List<dynamic> decoded = jsonDecode(jsonStr);
      if (mounted) {
        setState(() {
          _insights = decoded.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error generating insights: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to generate dynamic insights.';
          _isLoading = false;
          // Fallback to static if generation fails
          _insights = [
            {
              "title": "Route Optimization",
              "description": "Steady speeds on expressways saved approximately 5% in fuel costs.",
              "type": "tip"
            },
            {
              "title": "Terrain Impact",
              "description": "Elevation changes on this route influenced overall efficiency.",
              "type": "terrain"
            },
            {
              "title": "Sustainability",
              "description": "Your current driving pattern is 12% more eco-friendly than average.",
              "type": "eco"
            }
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.primaryMain),
                const SizedBox(width: 8),
                Text(
                  'Route Insights',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (_isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.textTertiary),
                onPressed: _loadInsights,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _error!,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.insightRed, fontWeight: FontWeight.w500),
            ),
          ),
        if (_insights.isEmpty && !_isLoading)
          const Text('No insights available for this route.')
        else
          ..._insights.map((insight) {
            final config = _getInsightConfig(insight['type'] ?? 'tip');
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildInsightCard(
                title: insight['title'] ?? 'Insight',
                description: insight['description'] ?? '',
                icon: config.icon,
                iconBackgroundColor: config.bgColor,
                iconColor: config.iconColor,
              ),
            );
          }),
      ],
    );
  }

  _InsightUIConfig _getInsightConfig(String type) {
    switch (type.toLowerCase()) {
      case 'savings':
        return _InsightUIConfig(
          icon: Icons.trending_down,
          bgColor: AppColors.insightBlueBg,
          iconColor: AppColors.textSecondary,
        );
      case 'terrain':
        return _InsightUIConfig(
          icon: Icons.terrain,
          bgColor: AppColors.insightYellowBg,
          iconColor: AppColors.textTertiary,
        );
      case 'eco':
        return _InsightUIConfig(
          icon: Icons.energy_savings_leaf_outlined,
          bgColor: const Color(0xFFE8F5E9),
          iconColor: Colors.green,
        );
      case 'tip':
      default:
        return _InsightUIConfig(
          icon: Icons.tips_and_updates_outlined,
          bgColor: AppColors.insightRedBg,
          iconColor: AppColors.insightRed,
        );
    }
  }

  Widget _buildInsightCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceDim.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
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

class _InsightUIConfig {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  _InsightUIConfig({required this.icon, required this.bgColor, required this.iconColor});
}


