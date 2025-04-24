import 'package:flutter/material.dart';
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
  final List<String> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  final List<String> _menuTitles = ['오늘', '다음 7일', '기본함'];

  void _addTask(String task) {
    if (task.isNotEmpty) {
      setState(() {
        _tasks.add(task);
      });
      _taskController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: _isRailExpanded,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.today),
                label: Text('오늘'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_view_week),
                label: Text('다음 7일'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.folder),
                label: Text('기본함'),
              ),
            ],
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          setState(() {
                            _isRailExpanded = !_isRailExpanded;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _menuTitles[_selectedIndex],
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TaskInput(controller: _taskController, onSubmit: _addTask),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TaskList(tasks: _tasks),
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