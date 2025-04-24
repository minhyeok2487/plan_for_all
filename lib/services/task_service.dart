import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService extends ChangeNotifier {
  final SupabaseClient supabase;
  final List<String> _tasks = [];

  TaskService(this.supabase);

  List<String> get tasks => List.unmodifiable(_tasks);

  Future<void> fetchTasks() async {
    final response = await supabase.from('todos').select('title');
    _tasks
      ..clear()
      ..addAll(response.map<String>((e) => e['title'] as String));
    notifyListeners();
  }

  Future<void> addTask(String task) async {
    if (task.isEmpty) return;

    _tasks.add(task);
    notifyListeners();

    try {
      await supabase.from('todos').insert({'title': task});
    } catch (_) {
      _tasks.remove(task);
      notifyListeners();
    }
  }
}
