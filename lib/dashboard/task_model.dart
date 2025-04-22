class Task {
  final String id;
  final String title;
  final bool isComplete;
  final DateTime createdAt;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.isComplete,
    required this.createdAt,
    required this.userId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'] as String,
      isComplete: json['is_complete'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_complete': isComplete,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    bool? isComplete,
    DateTime? createdAt,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
