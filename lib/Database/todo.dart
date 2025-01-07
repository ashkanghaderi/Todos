import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String details;

  @HiveField(3)
  final bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.details,
    required this.completed,
  });
}