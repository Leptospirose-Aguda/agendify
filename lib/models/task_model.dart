class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    this.deadline,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final DateTime? deadline;
  final bool isCompleted;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline'] as String) : null,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}
