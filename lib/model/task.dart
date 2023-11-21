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

  @HiveField(6)
  String? imagePath; // Add this field for imagePath

  Task({
    required this.accessType,
    required this.taskDescription,
    required this.taskId,
    required this.taskName,
    required this.taskTag,
    required this.isCompleted,
    this.imagePath, // Update the constructor to include imagePath
  });

  Map<String, dynamic> getdata() => {
        'accessType': accessType,
        'taskId': taskId,
        'taskName': taskName,
        'taskDescription': taskDescription,
        'taskTag': taskTag,
        'isCompleted': isCompleted,
        'imagePath': imagePath, // Include imagePath in the map
      };

  static Task getTask(Map<String , dynamic> map){

    return Task(
      accessType: map['accessType'],
      taskDescription: map['taskDescription'], 
      taskId: map['taskId'], 
      taskName: map['taskName'], 
      taskTag: map['taskTag'], 
      isCompleted: map['isCompleted']
      );

  }
}
