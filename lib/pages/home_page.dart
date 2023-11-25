import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/data/database.dart';
import 'package:flutter_application_4/hidden/hidden_home_page.dart';
import 'package:flutter_application_4/model/task.dart';
import 'package:flutter_application_4/model/user.dart';
import 'package:flutter_application_4/notification_Service/notifi_service.dart';
import 'package:flutter_application_4/pages/login_or_register.dart';
import 'package:flutter_application_4/services/auth_service.dart';
import 'package:flutter_application_4/services/storage_service.dart';
import 'package:flutter_application_4/util/dialog_box.dart';

import '../util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  //refrence to the box
  ToDoDataBase db = ToDoDataBase();
  String? userEmail;
  int sortingType = 3;

  //text controller
  final _controller = TextEditingController();
  final _desciptionController = TextEditingController();
  final List<String> taskTag = ["Work"];
  final List<String> accessTags = ["Public"];

  int generateRandomNumber(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }

  @override
  void initState() {
    //if this is the first time ever opening the app,then create default data
    // // if (_myBox.get("TODOLIST") == null) {
    //   db.createInitialData();
    // } else {
    //   //not the first time opening app
    //   db.loadData();
    // }
    super.initState();
    loadUserData();

    WidgetsBinding.instance.addObserver(this);
  }

  void loadUserData() async {
    DocumentReference ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    print(FirebaseAuth.instance.currentUser!.uid);
    DocumentSnapshot snap = await ref.get();

    MyUser user = MyUser.getUser(snap);
    setState(() {
      userEmail = user.email;
      db.createInitialData();
    });

    print(db.hiddenToDoList.length);
  }

  //check box was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index].isCompleted = !db.toDoList[index].isCompleted;
    });
    db.updateDataBase(sortingType);
  }

  void saveNewTask(File? image, DateTime? scheduleTime) async {
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
    int newId = generateRandomNumber(100000, 999999);
    String? imageUrl;
    if (image != null) {
      imageUrl = await Storage.uploadImage(image, newId);
      if (imageUrl != null) {
        print("Image uploaded. Download URL: $imageUrl");
      } else {
        print("Image upload failed.");
      }
    }

    setState(() {
      Task newTask = Task(
        accessType: accessTags[0],
        taskDescription: _desciptionController.text,
        taskId: newId,
        taskName: _controller.text,
        taskTag: taskTag[0],
        isCompleted: false,
        imagePath: imageUrl,
        timeStamp: scheduleTime,
      );

      if (scheduleTime != null) {
        debugPrint('Notification Scheduled for $scheduleTime');
        NotificationService().scheduleNotification(
            id: newTask.taskId,
            title: newTask.taskName.length > 15
                ? '${newTask.taskName.substring(0, 15)}...'
                : newTask.taskName,
            body: newTask.taskDescription.length > 20
                ? '${newTask.taskDescription.substring(0, 20)}...'
                : newTask.taskDescription,
            scheduledNotificationDateTime: newTask.timeStamp!);
      }

      // print(newTask.imagePath);

      if (accessTags[0] == "Public") {
        db.toDoList.add(newTask);
      } else {
        db.hiddenToDoList.add(newTask);
      }

      _controller.clear();
      _desciptionController.clear();
    });

    Navigator.of(context).pop();
    db.updateDataBase(sortingType);
  }

  //create a new task
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          accessTags: accessTags,
          controller: _controller,
          descriptionController: _desciptionController,
          taskTag: taskTag,
          onSave: saveNewTask,
          oncancel: () => Navigator.of(context).pop(),
          image: null,
        );
      },
    );
  }

  //delete task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase(sortingType);
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    MyUser.instance!.reset();
    AuthService().googleSignOut();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()));
  }

  void edit(List t) {
    int index = t[0];
    Task updatedTask = t[1];

    setState(() {
      db.toDoList[index] = updatedTask;
    });

    Navigator.of(context).pop();
    db.updateDataBase(sortingType);
  }

  void onAccessChanged(List t) {
    int index = t[0];
    Task changingTask = t[1];

    setState(() {
      db.toDoList.removeAt(index);
      db.hiddenToDoList.add(changingTask);
    });
    Navigator.of(context).pop();
    db.updateDataBase(sortingType);
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

  void onAppClosed() async {
    // Your method logic when the app is closed
    MyUser user = MyUser.instance!;

    // user.tasks = db.toDoList;
    List<Task> list = [];

    for (int i = 0; i < db.toDoList.length; i++) {
      list.add(db.toDoList[i]);
    }

    for (int i = 0; i < db.hiddenToDoList.length; i++) {
      list.add(db.hiddenToDoList[i]);
    }

    user.tasks = list;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.userId)
        .set(user.getdata());

    // Add your custom logic here
  }

  //access private task
  void makePrivate() {
    if (MyUser.instance!.password == "") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HiddenHomePage(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (builder) {
          String enteredPassword = ''; // Variable to store the entered password

          return AlertDialog(
            title: const Text('Enter Password'),
            content: TextField(
              obscureText: true,
              onChanged: (value) {
                enteredPassword = value;
              },
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // Check if the entered password is correct
                  if (enteredPassword == MyUser.instance!.password) {
                    // Password is correct, navigate to the next screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HiddenHomePage(),
                      ),
                    );
                  } else {
                    // Incorrect password, show a message
                    _showPasswordIncorrectDialog(context);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    }
  }

  void showEmailDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Account Information'),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Email: $email'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPasswordIncorrectDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Incorrect Password'),
          content: const Text('The entered password is incorrect.'),
          actions: <Widget>[
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ],
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                showEmailDialog(context, userEmail ?? "");
                // Handle account icon button tap (if needed)
              },
              icon: const Icon(Icons.account_circle),
            ),
            const SizedBox(width: 100), // Add some spacing
            InkWell(
              onTap: makePrivate,
              child: const Text('TO DO'),
            ),
          ],
        ),
        elevation: 0,
      ),

      //button to add the tasks
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: createNewTask,
            child: const Icon(Icons.add),
          ),
          const SizedBox(
            height: 16,
          ),
          FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.tag),
                        title: const Text('Task Tag'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            sortingType = 1;
                          });
                          db.updateDataBase(sortingType);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.abc),
                        title: const Text('A-Z'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            sortingType = 2;
                          });
                          db.updateDataBase(sortingType);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.access_alarm),
                        title: const Text('Remaining Time'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            sortingType = 3;
                          });
                          db.updateDataBase(sortingType);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(Icons.sort),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      //build a dynamic list so that we can add later by + button
      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          Task t = db.toDoList[index];
          return ToDoTile(
            accessType: t.accessType,
            onChanged: (value) => checkBoxChanged(value, index),
            onEdited: edit,
            taskCompleted: t.isCompleted,
            taskName: t.taskName,
            taskId: t.taskId,
            description: t.taskDescription,
            deleteFunction: (context) => deleteTask(index),
            taskTag: t.taskTag,
            imagePath: t.imagePath,
            onAccessChanged: onAccessChanged,
            timeStamp: t.timeStamp,
          );
        },
      ),
    );
  }
}
