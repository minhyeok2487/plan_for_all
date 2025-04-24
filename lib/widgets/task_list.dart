import 'package:flutter/material.dart';
import 'package:plan_for_all/models/task.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final void Function(int id)? onDelete;
  final void Function(int id)? onToggleDone;

  const TaskList({
    super.key,
    required this.tasks,
    this.onDelete,
    this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          leading: Checkbox(
            value: task.isDone,
            onChanged: (_) => onToggleDone?.call(task.id),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isDone ? TextDecoration.lineThrough : null,
              color: task.isDone ? Colors.grey : null,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => onDelete?.call(task.id),
          ),
        );
      },
    );
  }
}

