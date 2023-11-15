import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/util/my_button.dart';

// ignore: must_be_immutable
class DialogBox extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController descriptionController;
  final List<String> taskTag;
  VoidCallback onSave;
  VoidCallback oncancel;

  DialogBox({
    super.key,
    required this.controller,
    required this.descriptionController,
    required this.taskTag,
    required this.oncancel,
    required this.onSave,
  });

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  final List<String> taskTags = ['Work', 'School', 'Home', 'Other'];
  late String selectedValue = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[300],
      content: Container(
        height: 400,
        width: 400,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          //get user input
          TextField(
            controller: widget.controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Add a new task",
            ),
          ),
          TextField(
            
            controller: widget.descriptionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Add description",
            ),
          ),

          //task tag
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField2(
                  
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  isExpanded: true,
                  hint: Text(
                    widget.taskTag[0] == 'new' ? "Add a task tag" : widget.taskTag[0],
                    style: const TextStyle(fontSize: 14),
                  ),

                  // validator: (value) => value == null
                  //     ? 'Please select the task tag' : null,
                  items: taskTags
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) => setState(
                    () {
                      if (value != null) {selectedValue = value; widget.taskTag[0] = value;}
                    },
                  ),
                ),
              ),
            ],
          ),
          //buttons -> save+ cancel
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //save button
              MyButton(
                  text: "save",
                  onPressed: () {
                    // Pass the selected task tag to the onSave callback
                    widget.onSave();
                  }),

              const SizedBox(width: 8),
              //cancel button
              MyButton(text: "cancel", onPressed: widget.oncancel),
            ],
          )
        ]),
      ),
    );
  }
}
