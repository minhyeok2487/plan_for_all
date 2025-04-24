import 'package:flutter/material.dart';
import 'package:plan_for_all/widgets/task_input.dart';
import 'package:plan_for_all/widgets/task_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final response = await supabase.from('todos').select('title');
    final List<String> fetchedTasks = response.map<String>((e) => e['title'] as String).toList();

    setState(() {
      _tasks.clear();
      _tasks.addAll(fetchedTasks);
    });
  }

  Future<void> _addTask(String task) async {
    if (task.isEmpty) return;

    // 1. 먼저 UI에 추가
    setState(() {
      _tasks.add(task);
    });
    _taskController.clear();

    // 2. 서버에 저장 시도
    try {
      await supabase.from('todos').insert({'title': task});
    } catch (e) {
      // 3. 실패하면 롤백
      setState(() {
        _tasks.remove(task);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('할 일 추가 실패')),
      );
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