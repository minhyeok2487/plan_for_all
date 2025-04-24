import 'package:flutter/material.dart';
import 'package:plan_for_all/services/task_service.dart';
import 'package:provider/provider.dart';
import 'package:plan_for_all/widgets/task_input.dart';
import 'package:plan_for_all/widgets/task_list.dart';
import 'package:plan_for_all/widgets/main_navigation_rail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isRailExpanded = true;
  final TextEditingController _taskController = TextEditingController();
  final List<String> _menuTitles = ['오늘', '다음 7일', '기본함'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<TaskService>().fetchTasks()
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskService = context.watch<TaskService>();

    return Scaffold(
      body: Row(
        children: [
          MainNavigationRail(
            isExpanded: _isRailExpanded,
            selectedIndex: _selectedIndex,
            onSelect: (index) => setState(() => _selectedIndex = index),
            onToggle: () => setState(() => _isRailExpanded = !_isRailExpanded),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => setState(() => _isRailExpanded = !_isRailExpanded),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _menuTitles[_selectedIndex],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TaskInput(
                    controller: _taskController,
                    onSubmit: (title) async {
                      await taskService.addTask(title, ''); // description은 비워서 추가
                      _taskController.clear();
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TaskList(
                      tasks: taskService.tasks,
                      onDelete: (id) => taskService.deleteTask(id),
                      onToggleDone: (id) => taskService.toggleTaskDone(id),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
