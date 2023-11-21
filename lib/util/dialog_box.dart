import 'dart:io';

import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/notification_Service/notification.dart';
import 'package:flutter_application_4/util/my_button.dart';
import 'package:image_picker/image_picker.dart';

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
  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

    DateTime selectedDate = DateTime.now();
  DateTime fullDate = DateTime.now();

  final NotificationService _notificationService = NotificationService();

  Future<DateTime> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        initialDate: selectedDate,
        lastDate: DateTime(2100));
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );
      if (time != null) {
        setState(() {
          fullDate = DateTimeField.combine(date, time);
        });

         await _notificationService.scheduleNotifications(
            id: 1,
            title: widget.controller,
            body: widget.descriptionController,
            time: fullDate);
        
      }
      return DateTimeField.combine(date, time);
    } else {
      return selectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[300],
      content: Container(
        // height: 400,
        // width: 400,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                // Image selector
                GestureDetector(
                  onTap: _getImage,
                  child: _image == null
                      ? Container(
                          height: 100,
                          width: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.camera_alt),
                          ),
                        )
                      : Image.file(_image!),
                ),

                //buttons -> save + cancel
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //save button
                    MyButton(
                      text: "Save",
                      onPressed: () {
                        // Pass the selected task tag to the onSave callback
                        widget.onSave();
                      },
                    ),

                    const SizedBox(width: 55),

                    //cancel button
                    MyButton(text: "Cancel", onPressed: widget.oncancel),
                    
                    
                  ],
                ),
                Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                             ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: const Text("Add reminder"))
                      ],
                    )
              ]),
        ),
      ),
    );
  }
}
