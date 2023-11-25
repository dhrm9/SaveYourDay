import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/data/database.dart';
import 'package:flutter_application_4/model/task.dart';
import 'package:flutter_application_4/model/user.dart';
import 'package:flutter_application_4/pages/home_page.dart';
import 'package:flutter_application_4/util/todo_tile.dart';

// Stateful widget for the Hidden Home Page
class HiddenHomePage extends StatefulWidget {
  const HiddenHomePage({super.key});

  @override
  State<HiddenHomePage> createState() => _HiddenHomePageState();
}

// State class for the Hidden Home Page
class _HiddenHomePageState extends State<HiddenHomePage>
    with WidgetsBindingObserver {
  // Instance of the ToDoDataBase class to manage the database
  ToDoDataBase db = ToDoDataBase.instance!;
  int sortingType = 1;

  @override
  void initState() {
    super.initState();
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

  // Method to execute when the app is closed
  void onAppClosed() async {
    MyUser user = MyUser.instance!;

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
  }

  // Method to update the user's password
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
                  } catch (error) {
                    print('Error updating password: $error');
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

  // Method to handle checkbox state change
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.hiddenToDoList[index].isCompleted =
          !db.hiddenToDoList[index].isCompleted;
    });
    db.updateDataBase(sortingType);
  }

  // Method to handle task editing
  void edit(List t) {
    int index = t[0];
    Task updatedTask = t[1];

    setState(() {
      db.hiddenToDoList[index] = updatedTask;
    });

    Navigator.of(context).pop();
    db.updateDataBase(sortingType);
  }

  // Method to handle access change (from hidden to public)
  void onAccessChanged(List t) {
    int index = t[0];
    Task changingTask = t[1];

    setState(() {
      db.hiddenToDoList.removeAt(index);
      db.toDoList.add(changingTask);
    });
    Navigator.of(context).pop();
    db.updateDataBase(sortingType);
  }

  // Method to delete a hidden task
  void deleteTask(int index) {
    setState(() {
      db.hiddenToDoList.removeAt(index);
    });
    db.updateDataBase(sortingType);
  }

  @override
Widget build(BuildContext context) {
  // Create a scaffold with a grey background
  return Scaffold(
    backgroundColor: Colors.grey,

    // Define the app bar
    appBar: AppBar(
      // Set the app bar title to a row of widgets
      title: Row(
        children: [
          // Add an icon button to go back to the home page
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
            icon: const Icon(Icons.arrow_back),
          ),

          // Add a spacer to create space between the icon button and the text
          const SizedBox(width: 80),

          // Add the text "Hidden Tasks"
          const Text('Hidden Tasks'),
        ],
      ),

      // Add an icon button to update the password
      actions: [
        IconButton(
          onPressed: updatePassword,
          icon: const Icon(Icons.password_outlined),
        ),
      ],
    ),

    // Add a floating action button to sort tasks
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Add a list tile to sort tasks by tag
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

                // Add a list tile to sort tasks alphabetically
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

                // Add a list tile to sort tasks by remaining time
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

    // Create a list view of hidden tasks
    body: ListView.builder(
      itemCount: db.hiddenToDoList.length,
      itemBuilder: (context, index) {
        // Get the task at the current index
        Task t = db.hiddenToDoList[index];

        // Create a ToDoTile widget to display the task
        return ToDoTile(
          timeStamp: t.timeStamp,
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