import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_4/model/task.dart';
import 'package:flutter_application_4/notification_Service/notifi_service.dart';
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
  final DateTime? timeStamp;

  Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;
  Function(List) onEdited;
  Function(List) onAccessChanged;
  // add this line

  // ignore: use_key_in_widget_constructors
  ToDoTile({
    required this.accessType,
    required this.onChanged,
    required this.taskCompleted,
    required this.description,
    required this.taskName,
    required this.deleteFunction,
    required this.taskTag,
    required this.taskId,
    required this.onEdited,
    required this.imagePath,
    required this.onAccessChanged,
    required this.timeStamp,
  });

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
          timeStamp: widget.timeStamp,
        )),
      ),
    );
  }

  void _editTask() {
  // Create TextEditingControllers to store the edited task name and description
  TextEditingController taskNameController = TextEditingController(text: widget.taskName);
  TextEditingController descriptionController = TextEditingController(text: widget.description);

  // Create a list to store the selected task tag
  List<String> s = [widget.taskTag];

  // Create a list to store the selected access type
  List<String> a = [widget.accessType];

  // Display a dialog with the task details and editing options
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return DialogBox(
        accessTags: a, // Pass the list of access types to the dialog
        controller: taskNameController, // Pass the task name controller to the dialog
        descriptionController: descriptionController, // Pass the task description controller to the dialog
        taskTag: s, // Pass the selected task tag to the dialog
        image: widget.imagePath, // Pass the task image to the dialog
        onSave: (File? image, DateTime? scheduleTime) async { // Callback function for saving changes
          // Get the appropriate task list based on the access type
          List todoList;
          if (widget.accessType == "Public") {
            todoList = Hive.box('mybox').get("TODOLIST");
          } else {
            todoList = Hive.box('mybox').get("HIDDENTODOLIST");
          }

          // Upload the new image if provided
          String? imageUrl;
          if (image != null) {
            imageUrl = await Storage.uploadImage(image, widget.taskId);
            if (imageUrl != null) {
              print("Image uploaded. Download URL: $imageUrl");
            } else {
              print("Image upload failed.");
            }
          }

          // Iterate through the task list to find the task being edited
          for (int i = 0; i < todoList.length; i++) {
            Task c = todoList[i];
            if (c.taskId == widget.taskId) {
              // Update the task details with the edited values
              c.taskName = taskNameController.text;
              c.taskDescription = descriptionController.text;
              c.taskTag = s[0];
              c.accessType = a[0];
              c.imagePath = imageUrl ?? widget.imagePath; // Use the uploaded image URL or the original image URL

              // If the access type has changed, notify the parent widget
              if (a[0] != widget.accessType) {
                widget.onAccessChanged([i, c]);
              } else {
                // If the access type hasn't changed, notify the parent widget about the edited task
                widget.onEdited([i, c]);
              }

              // If a schedule time is provided, update the task's timestamp and schedule a notification
              if (scheduleTime != null) {
                c.timeStamp = scheduleTime;
                NotificationService().deleteScheduledNotification(c.taskId); // Delete any existing notification for the task
                debugPrint('Notification Scheduled for $scheduleTime'); // Print a debug message
                NotificationService().scheduleNotification( // Schedule a new notification
                  id: c.taskId,
                  title: c.taskName.length > 15 // Truncate the title if it's too long
                    ? '${c.taskName.substring(0, 15)}...'
                    : c.taskName,
                  body: c.taskDescription.length > 20 // Truncate the body if it's too long
                    ? '${c.taskDescription.substring(0, 20)}...'
                    : c.taskDescription,
                  scheduledNotificationDateTime: c.timeStamp!,
                );
              }

              // Clear the text controllers to prepare for the next edit
              taskNameController.clear();
              descriptionController.clear();
              break; // Stop iterating once the task is found and updated
            }
          }
        },
        oncancel: () {
          // Close the dialog if the user cancels the editing
          Navigator.pop(context);
        },
      );
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
        padding: const EdgeInsets.only(left: 25.0, right: 25, top: 15),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              //slidable delete function
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
                            widget.taskName.length > 15
                                ? '${widget.taskName.substring(0, 15)}...'
                                : widget.taskName,
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
                            widget.description.length > 20
                                ? '${widget.description.substring(0, 20)}...'
                                : widget.description,
                            style: TextStyle(
                              decoration: widget.taskCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          )
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
