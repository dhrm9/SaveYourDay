import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_4/model/task.dart';

class MyUser {
  String userId;
  String email;
  String password;
  List<Task> tasks;

  // Private static instance variable
  static MyUser? instance;

  // Private constructor
  MyUser._({
    required this.password,
    required this.email,
    required this.userId,
    required this.tasks,
  });

  // Factory constructor to provide a single instance of the class
  factory MyUser({
    required String password,
    required String email,
    required String userId,
    required List<Task> tasks,
  }) {
    // If an instance doesn't exist, create one; otherwise, return the existing instance
    instance ??= MyUser._(
      password: password,
      email: email,
      userId: userId,
      tasks: tasks,
    );
    // print("hello");
    return instance!;
  }

  Map<String, dynamic> getdata(){
    List<Map<String , dynamic>> list = [];

    for(int i = 0 ;i < tasks.length ; i++){
      list.add(tasks[i].getdata());
    }

    return {
      'email':email,
      'password': password,
      'tasks' : list,
      'userId' : userId
    };
  }
  
  static MyUser getUser(DocumentSnapshot snap){
    Map<String , dynamic> map = snap.data() as Map<String , dynamic>;

    List<dynamic> taskListMap = map['tasks'];

    List<Task> taskList = [];

    for(int i = 0 ;i < taskListMap.length ; i++){
      taskList.add(Task.getTask(taskListMap[i]));
    }

    return MyUser(password: map['password'], email: map['email'], userId: map['userId'], tasks: taskList);
  }
}
