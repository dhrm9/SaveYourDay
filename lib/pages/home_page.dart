import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/data/database.dart';
import 'package:flutter_application_4/util/dialog_box.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //refrence to the box
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

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
  }

  //text controller
  final _controller = TextEditingController();
  final _desciptionController = TextEditingController();

  //check box was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][2] = !db.toDoList[index][2];
    });
    db.updateDataBase();
  }

  //save new task
  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, _desciptionController.text, false]);
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
          onSave: saveNewTask,
          onCancle: () => Navigator.of(context).pop(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        actions: [IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))],
        title: Text('TO DO'),
        elevation: 0,
      ),

      //button to add the tasks
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: Icon(Icons.add),
      ),

      
      //build a dynamic list so that we can add later by + button
      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          return ToDoTile(
            onChanged: (value) => checkBoxChanged(value, index),
            taskCompleted: db.toDoList[index][2],
            taskName: db.toDoList[index][0],
            description: db.toDoList[index][1],
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
    );
  }
}
