import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'models/timeline_stop.dart';
import 'widgets/timeline_header.dart';
import 'widgets/timeline_item_card.dart';
import 'widgets/timeline_insight_card.dart';

class TimelineScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final ScrollController? scrollController;
  final List<TimelineStop> stops;
  final String? aiInsight;

  const TimelineScreen({
    super.key,
    this.onBack,
    this.scrollController,
    this.stops = const [],
    this.aiInsight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceMain,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: TimelineHeader(
              origin: stops.isNotEmpty ? stops.first.title : 'Origin',
              destination: stops.isNotEmpty ? stops.last.title : 'Destination',
            ),
          ),
          if (stops.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No timeline data available.')),
            )
          else
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
          if (aiInsight != null)
            SliverToBoxAdapter(
              child: TimelineInsightCard(
                text: aiInsight!,
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}
