import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/util/my_button.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class DialogBox extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController descriptionController;
  final List<String> taskTag;
  final List<String> accessTags;
  String? image;

  Function(File? , DateTime?) onSave;
  VoidCallback oncancel;

  DialogBox({
    super.key,
    required this.controller,
    required this.accessTags,
    required this.descriptionController,
    required this.taskTag,
    required this.oncancel,
    required this.onSave,
    required this.image,
  });

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  final List<String> taskTags = ['Work', 'School', 'Home', 'Other'];
  final List<String> accessTags = ['Public', 'Private'];
  late String selectedAccessTag = '';
  late String selectedValue = '';
  File? _image;
  DateTime? scheduleTime;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void getDateTime(){
     DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          onChanged: (date) => scheduleTime = date,
          onConfirm: (date) {},
        );
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //backgroundColor: Colors.blue[100],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Add Task Details",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),

          // reminder icon 
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey, // Set the color of the box
            ),
            padding: const EdgeInsets.all(8.0), // Adjust padding as needed
            child: GestureDetector(
              onTap: getDateTime,
              child: const Icon(
                Icons.alarm,
                color: Colors.white, // Set the color of the icon
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          //task access tag
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
                    widget.accessTags[0] == 'new'
                        ? "Add access Type"
                        : widget.accessTags[0],
                    style: const TextStyle(fontSize: 14),
                  ),
                  items: accessTags
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
                      if (value != null) {
                        selectedAccessTag = value;
                        widget.accessTags[0] = value;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          //get user input
          TextField(
            controller: widget.controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter task name",
            ),
          ),

          const SizedBox(height: 5),

          TextField(
            controller: widget.descriptionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter description",
            ),
          ),

          const SizedBox(height: 5),
          // task tag
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
                    widget.taskTag[0] == 'new'
                        ? "Add a task tag"
                        : widget.taskTag[0],
                    style: const TextStyle(fontSize: 14),
                  ),
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
                      if (value != null) {
                        selectedValue = value;
                        widget.taskTag[0] = value;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Image selector
          GestureDetector(
            onTap: _getImage,
            child: _image == null
                ? widget.image == null
                    ? Container(
                        height: 65,
                        width: 225,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.camera_alt),
                        ),
                      )
                    : Image.network(widget.image!)
                : SizedBox(
                    height: 270, // Specify your desired height
                    width: 250, // Specify your desired width
                    child: Image.file(_image!),
                  ),
          ),
          const SizedBox(height: 8),
          //buttons -> save + cancel
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //save button
              MyButton(
                text: "Save",
                onPressed: () {
                  // Pass the selected task tag to the onSave callback
                  widget.onSave(_image , scheduleTime);
                },
              ),

              const SizedBox(
                width: 50,
              ),
              //cancel button
              Column(
                children: [
                  MyButton(text: "Cancel", onPressed: widget.oncancel),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
