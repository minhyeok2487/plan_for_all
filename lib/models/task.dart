class Task {
  final int id;
  final DateTime createdAt;
  final String userId;
  String title;
  String description;
  final bool isDone;

  Task({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.title,
    required this.description,
    required this.isDone,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      isDone: map['is_done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'title': title,
      'description': description,
      'is_done': isDone,
    };
  }
}
