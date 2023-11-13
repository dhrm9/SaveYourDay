import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ToDoTile extends StatefulWidget {
  final String taskName;
  final bool taskCompleted;
  final String description;

  Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;
  // add this line

  ToDoTile({
    required this.onChanged,
    required this.taskCompleted,
    required this.description,
    required this.taskName,
    required this.deleteFunction,
  });

  @override
  State<ToDoTile> createState() => _ToDoTileState();
}

class _ToDoTileState extends State<ToDoTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25, top: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: widget.deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade300,
              borderRadius: BorderRadius.circular(12),
            )
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Checkbox and task information
              Row(
                children: [
                  Checkbox(
                    value: widget.taskCompleted,
                    onChanged: widget.onChanged,
                    activeColor: Colors.black,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        widget.description,
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
                child: IconButton(icon: Icon(Icons.edit), onPressed: () {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
