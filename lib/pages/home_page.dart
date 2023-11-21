import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/data/database.dart';
import 'package:flutter_application_4/hidden/hidden_home_page.dart';
import 'package:flutter_application_4/model/task.dart';
import 'package:flutter_application_4/model/user.dart';
import 'package:flutter_application_4/notification_Service/notification.dart';
import 'package:flutter_application_4/util/dialog_box.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  //refrence to the box
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  //text controller
  final _controller = TextEditingController();
  final _desciptionController = TextEditingController();
  final List<String> taskTag = ["new"]; 

  int generateRandomNumber(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }

  @override
  void initState() {
    //if this is the first time ever opening the app,then create default data
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      //not the first time opening app
      db.loadData();
    }

    super.initState();
    WidgetsBinding.instance.addObserver(this);

    loadUserData();
  }

  void loadUserData() async {
    DocumentReference ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    print(FirebaseAuth.instance.currentUser!.uid);
    DocumentSnapshot snap = await ref.get();

    MyUser user = MyUser.getUser(snap);


    print(user.email);
  }

  //check box was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index].isCompleted = !db.toDoList[index].isCompleted;
    });
    db.updateDataBase();
  }

  void saveNewTask() {
    // Check if the task name, description, and image path are not empty
    if (_controller.text.isEmpty || _desciptionController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                const Text('Task name, description, and image are required.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the method if there is an error
    }
   

    setState(() {
      int newId = generateRandomNumber(1000, 9999);

      Task newTask = Task(
        accessType: "Private",
        taskDescription: _desciptionController.text,
        taskId: newId,
        taskName: _controller.text,
        taskTag: taskTag[0],
        isCompleted: false,
      );

      db.toDoList.add(newTask);
      _controller.clear();
      _desciptionController.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  //create a new task
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          descriptionController: _desciptionController,
          taskTag: taskTag,
          onSave: saveNewTask,
          oncancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  //delete task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void edit(List t) {
    int index = t[0];
    Task updatedTask = t[1];

    setState(() {
      db.toDoList[index] = updatedTask;
    });

    Navigator.of(context as BuildContext).pop();
    db.updateDataBase();
  }

  @override
  void dispose() {
    // Remove the observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // The app is being put into the background or closed
      // Trigger your method here
      onAppClosed();
    }
  }

  void onAppClosed() async{
    // Your method logic when the app is closed
    MyUser user = MyUser.instance!;

    // user.tasks = db.toDoList;
    List<Task> list = [];

    for(int i = 0 ;i < db.toDoList.length ; i++){
      list.add(db.toDoList[i]);
    }

    user.tasks = list;

    await FirebaseFirestore.instance
          .collection('users')
          .doc(user.userId)
          .set(user.getdata());

    // Add your custom logic here
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ],
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HiddenHomePage()),
            );
          },
          child: const Text('TO DO'),
        ),
        elevation: 0,
      ),

      //button to add the tasks
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),

      //build a dynamic list so that we can add later by + button
      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          Task t = db.toDoList[index];
          return ToDoTile(
            onChanged: (value) => checkBoxChanged(value, index),
            onEdited: edit,
            taskCompleted: t.isCompleted,
            taskName: t.taskName,
            taskId: t.taskId,
            description: t.taskDescription,
            deleteFunction: (context) => deleteTask(index),
            taskTag: t.taskTag,
          );
        },
      ),
    );
  }
}
