import 'package:flutter_application_4/model/user.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Class responsible for managing the ToDo database
class ToDoDataBase {
  static ToDoDataBase? instance;

  ToDoDataBase._();

  factory ToDoDataBase() {
    instance ??= ToDoDataBase._();
    return instance!;
  }

  // Lists to store public and hidden tasks
  List toDoList = [];
  List hiddenToDoList = [];

  // Reference to the Hive box
  final _mybox = Hive.box('mybox');

  // Method to create initial data when the app is opening for the first time
  void createInitialData() {
    toDoList = [];
    hiddenToDoList = [];

    MyUser user = MyUser.instance!;

    // Populate the toDoList and hiddenToDoList based on user tasks
    for (int i = 0; i < user.tasks.length; i++) {
      if (user.tasks[i].accessType == "Public") {
        toDoList.add(user.tasks[i]);
      } else {
        hiddenToDoList.add(user.tasks[i]);
      }
    }

    // Update the database with the specified sorting choice
    updateDataBase(1);
  }

  // Method to load data from the database
  void loadData() {
    toDoList = _mybox.get("TODOLIST");
    hiddenToDoList = _mybox.get("HIDDENTODOLIST");
  }

  // Method to update the database based on the sorting choice
  void updateDataBase(int choice) {
    if (choice == 1) {
      // Sort tasks based on custom order defined by tagOrder
      Map<String, int> tagOrder = {
        'Work': 1,
        'School': 2,
        'Home': 3,
        'Other': 4,
      };

      toDoList.sort((task1, task2) {
        return tagOrder[task1.taskTag]!.compareTo(tagOrder[task2.taskTag]!);
      });

      hiddenToDoList.sort((task1, task2) {
        return tagOrder[task1.taskTag]!.compareTo(tagOrder[task2.taskTag]!);
      });
    } else if (choice == 2) {
      // Sort tasks based on task name
      toDoList.sort((task1, task2) {
        return task1.taskName.compareTo(task2.taskName);
      });

      hiddenToDoList.sort((task1, task2) {
        return task1.taskName.compareTo(task2.taskName);
      });
    } else if (choice == 3) {
      // Sort tasks based on remaining time
      toDoList.sort((task1, task2) {
        Duration a = task1.timeStamp == null
            ? const Duration(days: 99999)
            : task1.timeStamp.difference(DateTime.now());

        Duration b = task2.timeStamp == null
            ? const Duration(days: 99999)
            : task2.timeStamp.difference(DateTime.now());

        return a.inSeconds.compareTo(b.inSeconds);
      });

      hiddenToDoList.sort((task1, task2) {
        Duration a = task1.timeStamp == null
            ? const Duration(days: 99999)
            : task1.timeStamp.difference(DateTime.now());

        Duration b = task2.timeStamp == null
            ? const Duration(days: 99999)
            : task2.timeStamp.difference(DateTime.now());

        return a.inSeconds.compareTo(b.inSeconds);
      });
    }

    // Put sorted lists into Hive box
    _mybox.put("TODOLIST", toDoList);
    _mybox.put("HIDDENTODOLIST", hiddenToDoList);

    // Reload data after the update
    loadData();
  }
}
