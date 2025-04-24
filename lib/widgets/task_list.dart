import 'package:flutter/material.dart';

class TaskList extends StatelessWidget {
  final List<String> tasks;

  const TaskList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.check_box_outline_blank),
          title: Text(tasks[index]),
        );
      },
    );
  }
}
