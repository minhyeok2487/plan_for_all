import 'package:flutter/material.dart';
import 'package:plan_for_all/models/task.dart';
import 'package:plan_for_all/widgets/task_input.dart';
import 'package:plan_for_all/widgets/task_list.dart';

class TaskSection extends StatelessWidget {
  final TextEditingController controller;
  final List<Task> tasks;
  final Future<void> Function(String) onAdd;
  final void Function(int) onDelete;
  final void Function(int) onToggleDone;
  final void Function(Task) onSelect;

  const TaskSection({
    super.key,
    required this.controller,
    required this.tasks,
    required this.onAdd,
    required this.onDelete,
    required this.onToggleDone,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TaskInput(
          controller: controller,
          onSubmit: (title) async {
            await onAdd(title);
            controller.clear();
          },
        ),
        const SizedBox(height: 20),
        Expanded(
          child: TaskList(
            tasks: tasks,
            onDelete: onDelete,
            onToggleDone: onToggleDone,
            onSelect: onSelect,
          ),
        ),
      ],
    );
  }
}
