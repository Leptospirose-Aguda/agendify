class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.description,
    this.location,
    this.category,
    this.notes,
    this.isRecurring = false,
  });

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? description;
  final String? location;
  final String? category;
  final String? notes;
  final bool isRecurring;

  Duration get duration => end.difference(start);
}
