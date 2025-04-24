import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plan_for_all/widgets/task_ediitor.dart';
import 'package:plan_for_all/models/task.dart';
import 'package:plan_for_all/services/task_service.dart';
import 'package:provider/provider.dart';
import 'package:plan_for_all/widgets/main_navigation_rail.dart';
import 'package:plan_for_all/widgets/task_input.dart';
import 'package:plan_for_all/widgets/task_list.dart';

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
  Task? _selectedTask;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TaskService>().fetchTasks());
  }

  @override
  Widget build(BuildContext context) {
    final taskService = context.watch<TaskService>();
    final isMobile = MediaQuery.of(context).size.width < 600;
    bool _isRefreshing = false;

    return Scaffold(
      drawer: isMobile
          ? Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('메뉴', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            for (int i = 0; i < _menuTitles.length; i++)
              ListTile(
                title: Text(_menuTitles[i]),
                selected: i == _selectedIndex,
                onTap: () {
                  setState(() => _selectedIndex = i);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      )
          : null,
      body: Stack(
        children: [
          Row(
            children: [
              if (!isMobile) ...[
                MainNavigationRail(
                  isExpanded: _isRailExpanded,
                  selectedIndex: _selectedIndex,
                  onSelect: (index) => setState(() => _selectedIndex = index),
                  onToggle: () => setState(() => _isRailExpanded = !_isRailExpanded),
                ),
                const VerticalDivider(width: 1, thickness: 1),
              ],
              Expanded(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ 메뉴 버튼과 타이틀을 같은 줄에
                        Row(
                          children: [
                            if (isMobile)
                              Builder(
                                builder: (context) => IconButton(
                                  icon: const Icon(Icons.menu),
                                  onPressed: () => Scaffold.of(context).openDrawer(),
                                ),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () => setState(() => _isRailExpanded = !_isRailExpanded),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _menuTitles[_selectedIndex],
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              tooltip: '동기화',
                              onPressed: _isRefreshing
                                  ? null
                                  : () async {
                                setState(() => _isRefreshing = true);
                                await context.read<TaskService>().fetchTasks();
                                setState(() => _isRefreshing = false);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('동기화 완료'),
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              icon: _isRefreshing
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                                  : const Icon(Icons.refresh),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TaskInput(
                          controller: _taskController,
                          onSubmit: (title) async {
                            await taskService.addTask(title, '');
                            _taskController.clear();
                          },
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: TaskList(
                            tasks: taskService.tasks,
                            onDelete: (id) => taskService.deleteTask(id),
                            onToggleDone: (id) => taskService.toggleTaskDone(id),
                            onSelect: (task) => setState(() => _selectedTask = task),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_selectedTask != null)
            TaskEditor(
              task: _selectedTask!,
              onDismiss: () => setState(() => _selectedTask = null),
            ),
        ],
      ),
    );
  }
}
