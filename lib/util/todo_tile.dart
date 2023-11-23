import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_4/model/task.dart';
import 'package:flutter_application_4/services/storage_service.dart';
import 'package:flutter_application_4/util/dialog_box.dart';
import 'package:flutter_application_4/util/task_details.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';

// ignore: must_be_immutable
class ToDoTile extends StatefulWidget {
  final String taskName;
  final bool taskCompleted;
  final String description;
  final String taskTag;
  final int taskId;
  final String? imagePath;
  final String accessType;

  Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;
  Function(List) onEdited;
  Function(List) onAccessChanged;
  // add this line

  // ignore: use_key_in_widget_constructors
  ToDoTile(
      {required this.accessType,
      required this.onChanged,
      required this.taskCompleted,
      required this.description,
      required this.taskName,
      required this.deleteFunction,
      required this.taskTag,
      required this.taskId,
      required this.onEdited,
      required this.imagePath,
      required this.onAccessChanged});

  @override
  State<ToDoTile> createState() => _ToDoTileState();
}

class _ToDoTileState extends State<ToDoTile> {
  void _viewTaskDetails() {
    // Navigate to TaskDetailPage and pass the task details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(
            task: Task(
          accessType: widget.accessType,
          imagePath: widget.imagePath,
          taskId: widget.taskId,
          taskName: widget.taskName,
          taskDescription: widget.description,
          taskTag: widget.taskTag,
          isCompleted: widget.taskCompleted,
        )),
      ),
    );
  }

  void _editTask() {
    TextEditingController taskNameController =
        TextEditingController(text: widget.taskName);
    TextEditingController descriptionController =
        TextEditingController(text: widget.description);
    List<String> s = [widget.taskTag];
    List<String> a = [widget.accessType];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogBox(
            accessTags: a,
            controller: taskNameController,
            descriptionController: descriptionController,
            taskTag: s,
            image: widget.imagePath,
            onSave: (File? image) async {
              List todoList;
              if (widget.accessType == "Public") {
                todoList = Hive.box('mybox').get("TODOLIST");
              } else {
                todoList = Hive.box('mybox').get("HIDDENTODOLIST");
              }
              String? imageUrl;
              if (image != null) {
                imageUrl = await Storage.uploadImage(image, widget.taskId);
                if (imageUrl != null) {
                  print("Image uploaded. Download URL: $imageUrl");
                } else {
                  print("Image upload failed.");
                }
              }

              for (int i = 0; i < todoList.length; i++) {
                Task c = todoList[i];
                if (c.taskId == widget.taskId) {
                  c.taskName = taskNameController.text;
                  c.taskDescription = descriptionController.text;
                  c.taskTag = s[0];
                  c.accessType = a[0];
                  c.imagePath = imageUrl;
                  if (a[0] != widget.accessType) {
                    widget.onAccessChanged([i, c]);
                  } else {
                    widget.onEdited([i, c]);
                  }

                  taskNameController.clear();
                  descriptionController.clear();
                  break;
                }
              }
            },
            oncancel: () {
              Navigator.pop(context); // Close the dialog
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color taskColor = Colors.black;
    switch (widget.taskTag) {
      case 'Work':
        taskColor = Colors.green;
        break;
      case 'School':
        taskColor = Colors.blue;
        break;
      case 'Home':
        taskColor = Colors.red;
        break;
    }

    return GestureDetector(
      onTap: _viewTaskDetails,
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25, top: 25),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: widget.deleteFunction,
                icon: Icons.delete,
                backgroundColor: Colors.red.shade300,
                borderRadius: BorderRadius.circular(12),
              )
            ],
          ),
          //tile
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      //color box
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            color: taskColor,
                            borderRadius: BorderRadius.circular(100)
                            //more than 50% of width makes circle
                            ),
                      ),
                      // Checkbox and task information
                      Checkbox(
                        value: widget.taskCompleted,
                        onChanged: widget.onChanged,
                        activeColor: Colors.black,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //task details
                          Text(
                            widget.taskName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              decoration: widget.taskCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          //Description details
                          Text(
                            // widget.description,
                            widget.description.length > 30
                                ? widget.description.substring(0, 25) + '...'
                                : widget.description,
                            style: TextStyle(
                              decoration: widget.taskCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Edit button
                  GestureDetector(
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _editTask,
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
