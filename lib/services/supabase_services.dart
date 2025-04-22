import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techstax_assign/dashboard/task_model.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // Fetch all tasks for the current user
  Future<List<Task>> getTasks() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return [];
    }

    final response = await _supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((task) => Task.fromJson(task)).toList();
  }

  // Add a new task
  Future<void> addTask(String title) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _supabase.from('tasks').insert({
      'title': title,
      'is_complete': false,
      'user_id': userId,
    });
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _supabase.from('tasks').delete().eq('id', taskId);
  }

  // Toggle task completion status
  Future<void> toggleTaskComplete(String taskId, bool isComplete) async {
    await _supabase
        .from('tasks')
        .update({'is_complete': isComplete}).eq('id', taskId);
  }
}
