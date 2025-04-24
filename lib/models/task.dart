class Task {
  final int id;
  final DateTime createdAt;
  String title;
  String description;
  final bool isDone;

  Task({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.description,
    required this.isDone,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      isDone: map['is_done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'title': title,
      'description': description,
    };
  }
}
