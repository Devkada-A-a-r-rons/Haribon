import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'models/timeline_stop.dart';
import 'widgets/timeline_header.dart';
import 'widgets/timeline_item_card.dart';
import 'widgets/timeline_insight_card.dart';

class TimelineScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final ScrollController? scrollController;

  const TimelineScreen({
    super.key,
    this.onBack,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final stops = [
      const TimelineStop(
        type: TimelineStopType.departure,
        time: '08:00 AM',
        title: 'Metro Manila',
        description: 'Starting fuel level: 85%',
      ),
      const TimelineStop(
        type: TimelineStopType.refuel,
        time: '09:45 AM',
        title: 'Shell Angeles',
        description: 'Est. arrival with 42% fuel.\nRecommendation: Fill to 95%.',
        tags: ['V-Power Diesel', 'Deli2Go Available'],
        buttonText: 'CONFIRM STOP',
      ),
      const TimelineStop(
        type: TimelineStopType.optional,
        time: '11:15 AM',
        title: 'Sison, Pangasinan',
        description: 'Safety buffer stop. High traffic detected at Kennon Road.',
        buttonText: 'QUICK REST',
      ),
      const TimelineStop(
        type: TimelineStopType.arrival,
        time: '01:30 PM',
        title: 'Baguio City Central',
        description: 'Expected fuel remaining: 35%',
      ),
    ];

    return Container(
      color: AppColors.surfaceMain,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          const SliverToBoxAdapter(
            child: TimelineHeader(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final stop = stops[index];
                return TimelineItemCard(
                  stop: stop,
                  isFirst: index == 0,
                  isLast: index == stops.length - 1,
                );
              },
              childCount: stops.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: TimelineInsightCard(
              text: 'Based on current climb rates and ambient temperature of 24°C, your consumption will increase by 12% once you hit the Marcos Highway incline. Stopping at Shell Angeles is highly recommended to maintain a 20% safety reserve upon reaching the city center.',
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 10)),
        ],
      ),
    );
  }
}
