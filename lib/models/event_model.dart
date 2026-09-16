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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'description': description,
      'location': location,
      'category': category,
      'notes': notes,
      'isRecurring': isRecurring,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      start: DateTime.parse(map['start'] as String),
      end: DateTime.parse(map['end'] as String),
      description: map['description'] as String?,
      location: map['location'] as String?,
      category: map['category'] as String?,
      notes: map['notes'] as String?,
      isRecurring: map['isRecurring'] as bool? ?? false,
    );
  }
}
