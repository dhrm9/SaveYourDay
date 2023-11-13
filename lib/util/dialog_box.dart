
import 'package:flutter/material.dart';
import 'package:flutter_application_4/util/my_button.dart';

class DialogBox extends StatelessWidget {
  final controller;
  final descriptionController;
  VoidCallback onSave;
  VoidCallback onCancle;

   DialogBox({
    super.key,
    required this.controller,
    required this.descriptionController,
    required this.onCancle,
    required this.onSave,
    });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.yellow[300],
      content: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          //get user input
          TextField(
              controller: controller,
              decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "add a new task",
              ),
          ),
          TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "add description",
              ),
          ),
 
          //buttons -> save+ cancle
           Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //save button
              MyButton(text: "save", onPressed: onSave ),

              const SizedBox(width:8),
              //cancle button
              MyButton(text: "cancle", onPressed: onCancle),
            ],
           )
        ]),
        ),
    );
  }
}