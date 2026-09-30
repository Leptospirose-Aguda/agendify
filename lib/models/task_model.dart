class TaskModel {
  TaskModel({
    required this.id,
    required this.title,
    this.deadline,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
