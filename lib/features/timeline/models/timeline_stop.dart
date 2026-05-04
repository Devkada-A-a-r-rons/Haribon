enum TimelineStopType { departure, refuel, optional, arrival }

class TimelineStop {
  final TimelineStopType type;
  final String time;
  final String title;
  final String description;
  final List<String>? tags;
  final String? buttonText;

  const TimelineStop({
    required this.type,
    required this.time,
    required this.title,
    required this.description,
    this.tags,
    this.buttonText,
  });
}
