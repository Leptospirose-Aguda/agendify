class TaskModel {
  const TaskModel({
    this.id,
    required this.title,
    this.deadline,
    this.isCompleted = false,
  });

  final String? id;
  final String title;
  final DateTime? deadline;
  final bool isCompleted;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String).toLocal(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'deadline': deadline?.toUtc().toIso8601String(),
        'isCompleted': isCompleted,
      };

  TaskModel copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
