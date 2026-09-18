class EventModel {
  const EventModel({
    this.id,
    required this.title,
    required this.start,
    required this.end,
    this.description,
    this.location,
    this.category,
    this.notes,
    this.isRecurring = false,
  });

  final String? id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? description;
  final String? location;
  final String? category;
  final String? notes;
  final bool isRecurring;

  Duration get duration => end.difference(start);

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      start: DateTime.parse(json['start'] as String).toLocal(),
      end: DateTime.parse(json['end'] as String).toLocal(),
      description: json['description'] as String?,
      location: json['location'] as String?,
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
        'description': description,
        'location': location,
        'category': category,
        'notes': notes,
        'isRecurring': isRecurring,
      };

  EventModel copyWith({
    String? id,
    String? title,
    DateTime? start,
    DateTime? end,
    String? description,
    String? location,
    String? category,
    String? notes,
    bool? isRecurring,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      description: description ?? this.description,
      location: location ?? this.location,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}
