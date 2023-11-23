// task_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_4/model/task.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;

  TaskDetailPage({super.key, required this.task}){
    print(task.imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.imagePath != null) // Check if imagePath is not null
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(task
                        .imagePath!), // Assuming imagePath is a local asset path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (task.imagePath != null) SizedBox(height: 10),
            Text(
              'Image: ${task.imagePath}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Task Name: ${task.taskName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Description: ${task.taskDescription}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Tag: ${task.taskTag}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Completed: ${task.isCompleted ? 'Yes' : 'No'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
