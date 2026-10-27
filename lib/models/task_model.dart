class Task {
  int? id;
  int userId;
  String title;
  String description;
  String type; // Assignment / Exam / Class
  DateTime dueAt;
  int remindBefore; // কত মিনিট আগে alert
  bool done;

  Task({
    this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.type,
    required this.dueAt,
    this.remindBefore = 30,
    this.done = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'type': type,
    'dueAt': dueAt.millisecondsSinceEpoch,
    'remindBefore': remindBefore,
    'done': done ? 1 : 0,
  };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
    id: m['id'] as int,
    userId: m['userId'] as int,
    title: m['title'] as String,
    description: m['description'] as String,
    type: m['type'] as String,
    dueAt: DateTime.fromMillisecondsSinceEpoch(m['dueAt'] as int),
    remindBefore: m['remindBefore'] as int,
    done: m['done'] == 1,
  );
}