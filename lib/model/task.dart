import 'package:hive/hive.dart';

part "task.g.dart"; // Generated file will have the name task.g.dart

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String accessType;

  @HiveField(1)
  int taskId;

  @HiveField(2)
  String taskName;

  @HiveField(3)
  String taskDescription;

  @HiveField(4)
  String taskTag;

  @HiveField(5)
  bool isCompleted;

  Task({
    required this.accessType,
    required this.taskDescription,
    required this.taskId,
    required this.taskName,
    required this.taskTag,
    required this.isCompleted,
  });

  Map<String, dynamic> getdata() => {
        'accessType': accessType,
        'taskId': taskId,
        'taskName': taskName,
        'taskDescription': taskDescription,
        'taskTag': taskTag,
        'isCompleted': isCompleted,
      };
}