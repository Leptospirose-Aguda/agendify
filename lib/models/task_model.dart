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
}
