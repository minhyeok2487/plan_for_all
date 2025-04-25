import 'package:flutter/material.dart';
import 'package:plan_for_all/models/task.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:plan_for_all/providers/user_provider.dart';
import 'package:provider/provider.dart';

class TaskService extends ChangeNotifier {
  final SupabaseClient supabase;
  final List<Task> _tasks = [];

  TaskService(this.supabase);

  List<Task> get tasks => List.unmodifiable(_tasks);

  /// 로그인한 사용자의 task 가져오기
  Future<void> fetchTasks(BuildContext context) async {
    final userId = context.read<UserProvider>().user?.id;
    if (userId == null) return;

    final response = await supabase
        .from('tasks')
        .select('id, created_at, title, description, is_done, user_id')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    _tasks
      ..clear()
      ..addAll(response.map<Task>((e) => Task.fromMap(e)));
    notifyListeners();
  }

  /// task 추가 (user_id 포함)
  Future<void> addTask(BuildContext context, String title) async {
    if (title.isEmpty) return;

    final userId = context.read<UserProvider>().user?.id;
    if (userId == null) return;

    try {
      final inserted = await supabase
          .from('tasks')
          .insert({
        'title': title,
        'description': null,
        'user_id': userId, // ✅ user_id 포함
      })
          .select()
          .single();

      final task = Task.fromMap(inserted);
      _tasks.insert(0, task); // 최신 순
      notifyListeners();
    } catch (e) {
      // 에러 로깅 추가 가능
    }
  }

  /// task 삭제
  Future<void> deleteTask(int id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final removedTask = _tasks.removeAt(index);
    notifyListeners();

    try {
      await supabase.from('tasks').delete().eq('id', id);
    } catch (_) {
      _tasks.insert(index, removedTask); // 롤백
      notifyListeners();
    }
  }

  /// 완료 상태 토글
  Future<void> toggleTaskDone(int id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final oldTask = _tasks[index];
    final updatedTask = Task(
      id: oldTask.id,
      createdAt: oldTask.createdAt,
      userId: oldTask.userId,
      title: oldTask.title,
      description: oldTask.description,
      isDone: !oldTask.isDone,
    );

    _tasks[index] = updatedTask;
    notifyListeners();

    try {
      await supabase.from('tasks').update({'is_done': updatedTask.isDone}).eq('id', id);
    } catch (_) {
      _tasks[index] = oldTask;
      notifyListeners();
    }
  }

  /// task 수정
  Future<void> updateTask(int id, String title, String description) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final old = _tasks[index];
    final updated = Task(
      id: id,
      createdAt: old.createdAt,
      userId: old.userId,
      title: title,
      description: description,
      isDone: old.isDone,
    );

    _tasks[index] = updated;
    notifyListeners();

    try {
      await supabase.from('tasks').update({
        'title': title,
        'description': description,
      }).eq('id', id);
    } catch (_) {
      _tasks[index] = old;
      notifyListeners();
    }
  }

  void clearTasks() {
    _tasks.clear();
    notifyListeners();
  }

}
