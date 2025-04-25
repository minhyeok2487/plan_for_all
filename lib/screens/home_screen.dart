import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plan_for_all/providers/user_provider.dart';
import 'package:plan_for_all/widgets/task_ediitor.dart';
import 'package:plan_for_all/models/task.dart';
import 'package:plan_for_all/services/task_service.dart';
import 'package:provider/provider.dart';
import 'package:plan_for_all/widgets/home/main_navigation_rail.dart';
import 'package:plan_for_all/widgets/home/menu_drawer.dart';
import 'package:plan_for_all/widgets/home/menu_header.dart';
import 'package:plan_for_all/widgets/home/task_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isRailExpanded = true;
  bool _isRefreshing = false;
  final TextEditingController _taskController = TextEditingController();
  final List<String> _menuTitles = ['오늘', '다음 7일', '기본함'];
  Task? _selectedTask;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserProvider>().loadUser();
      context.read<TaskService>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskService = context.watch<TaskService>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      drawer: isMobile
          ? MenuDrawer(
              selectedIndex: _selectedIndex,
              menuTitles: _menuTitles,
              onTap: (index) => setState(() => _selectedIndex = index),
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
                  onToggle: () =>
                      setState(() => _isRailExpanded = !_isRailExpanded),
                ),
                const VerticalDivider(width: 1, thickness: 1),
              ],
              Expanded(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        MenuHeader(
                          isMobile: isMobile,
                          isExpanded: _isRailExpanded,
                          isRefreshing: _isRefreshing,
                          title: _menuTitles[_selectedIndex],
                          onMenuToggle: () {
                            if (isMobile) {
                              Scaffold.of(context).openDrawer();
                            } else {
                              setState(
                                  () => _isRailExpanded = !_isRailExpanded);
                            }
                          },
                          onRefresh: () async {
                            setState(() => _isRefreshing = true);
                            await taskService.fetchTasks();
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
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: TaskSection(
                            controller: _taskController,
                            tasks: taskService.tasks,
                            onAdd: (title) async {
                              await taskService.addTask(title, '');
                              _taskController.clear();
                            },
                            onDelete: (id) => taskService.deleteTask(id),
                            onToggleDone: (id) =>
                                taskService.toggleTaskDone(id),
                            onSelect: (task) =>
                                setState(() => _selectedTask = task),
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
