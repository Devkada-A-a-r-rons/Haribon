import 'package:flutter/material.dart';
import '../common/widgets/app_bar.dart';
import '../timeline/timeline_screen.dart';
import 'trip_summary_screen.dart';
import 'models/trip_summary_model.dart';

class MainSummaryScreen extends StatefulWidget {
  final TripSummary summary;

  const MainSummaryScreen({super.key, required this.summary});

  factory MainSummaryScreen.mock({Key? key}) =>
      MainSummaryScreen(key: key, summary: TripSummaryScreen.mock().summary);

  @override
  State<MainSummaryScreen> createState() => _MainSummaryScreenState();
}

class _MainSummaryScreenState extends State<MainSummaryScreen> {
  int _currentIndex = 0;
  final ScrollController _summaryScrollController = ScrollController();
  final ScrollController _timelineScrollController = ScrollController();

  void _switchToTimeline() {
    setState(() {
      _currentIndex = 1;
    });
    _timelineScrollController.jumpTo(0);
  }

  void _switchToSummary() {
    setState(() {
      _currentIndex = 0;
    });
    _summaryScrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: _currentIndex == 0 ? 'Trip Summary' : 'Timeline',
        leading: _currentIndex == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _switchToSummary,
              )
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TripSummaryScreen(
            summary: widget.summary,
            onSeeTimeline: _switchToTimeline,
            scrollController: _summaryScrollController,
          ),
          TimelineScreen(
            onBack: _switchToSummary,
            scrollController: _timelineScrollController,
          ),
        ],
      ),
    );
  }
}
