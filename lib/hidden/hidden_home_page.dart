import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/data/database.dart';
import 'package:flutter_application_4/model/task.dart';
import 'package:flutter_application_4/model/user.dart';
import 'package:flutter_application_4/pages/home_page.dart';
import 'package:flutter_application_4/util/todo_tile.dart';

class HiddenHomePage extends StatefulWidget {
  const HiddenHomePage({super.key});

  @override
  State<HiddenHomePage> createState() => _HiddenHomePageState();
}

class _HiddenHomePageState extends State<HiddenHomePage> with WidgetsBindingObserver{

  ToDoDataBase db = ToDoDataBase.instance!;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // print(db.hiddenToDoList.length);
    WidgetsBinding.instance.addObserver(this);

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

  void updatePassword() {
    showDialog(
      context: context,
      builder: (builder) {
        String enteredPassword = ''; // Variable to store the entered password

        return AlertDialog(
          title: const Text('Password'),
          content: TextField(
            obscureText: true,
            onChanged: (value) {
              enteredPassword = value;
            },
            decoration: const InputDecoration(
              labelText: 'Enter new password',
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
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                if (enteredPassword.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(MyUser.instance!.userId)
                        .update({
                      'password': enteredPassword,
                      // Add other fields to update as needed
                    });
                    MyUser.instance!.password = enteredPassword;
                    // print('Password  updated successfully!');
                    // print(MyUser.instance!.password);
                  } catch (error) {
                    print('Error updating password : $error');
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  //check box was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.hiddenToDoList[index].isCompleted = !db.hiddenToDoList[index].isCompleted;
    });
    db.updateDataBase();
  }

  
  void edit(List t) {
    int index = t[0];
    Task updatedTask = t[1];

    setState(() {
      db.hiddenToDoList[index] = updatedTask;
      print(index);
    });

    Navigator.of(context).pop();
    db.updateDataBase();
  }

  void onAccessChanged(List t){
    int index = t[0];
    Task changingTask = t[1];

    setState(() {
      db.hiddenToDoList.removeAt(index);
      db.toDoList.add(changingTask);
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

   //delete task
  void deleteTask(int index) {
    setState(() {
      db.hiddenToDoList.removeAt(index);
    });
    db.updateDataBase();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(onPressed: () {

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),));

            }, icon: const Icon(Icons.arrow_back)),
            const SizedBox(width: 100,),
            const Text('Hidden Tasks'),
          ],
        ),
        actions: [
          IconButton(
              onPressed: updatePassword,
              icon: const Icon(Icons.password_outlined))
        ],
      ),
      body: ListView.builder(
        itemCount: db.hiddenToDoList.length,
        itemBuilder: (context, index) {
          Task t = db.hiddenToDoList[index];
          return ToDoTile(
            //timeStamp: t.timeStamp,
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
          );
        },
      ),
    );
  }
}
