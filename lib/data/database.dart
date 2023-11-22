import 'package:flutter_application_4/model/user.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  
  List toDoList = [];

  //refrence our box
  final _mybox = Hive.box('mybox');

  //run this method if app is opening very first time
  void createInitialData() {
    toDoList = [];

    MyUser user = MyUser.instance!;

    for (int i = 0; i < user.tasks.length; i++) {
      toDoList.add(user.tasks[i]);
    }

    updateDataBase();
  }

  //load the data from database
  void loadData() {
    toDoList = _mybox.get("TODOLIST");
  }

  //update the database
  void updateDataBase() {
    Map<String, int> tagOrder = {
      'Work': 1,
      'School': 2,
      'Home': 3,
      'Other': 4,
    };

    // Sort the tasks based on the custom orde
    toDoList.sort((task1, task2) {
      return tagOrder[task1.taskTag]!.compareTo(tagOrder[task2.taskTag]!);
    });
    _mybox.put("TODOLIST", toDoList);
    loadData();
  }
}
