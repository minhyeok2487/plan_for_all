import 'package:flutter/material.dart';
import 'package:plan_for_all/models/task.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final void Function(int id)? onDelete;

  const TaskList({
    super.key,
    required this.tasks,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          leading: const Icon(Icons.check_box_outline_blank),
          title: Text(task.title),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => onDelete?.call(task.id),
          ),
        );
      },
    );
  }
}
