import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techstax_assign/app/theme.dart';
import 'package:techstax_assign/auth/auth_service.dart';
import 'package:techstax_assign/auth/login_screen.dart';
import 'package:techstax_assign/dashboard/task_model.dart';
import 'package:techstax_assign/dashboard/task_tile.dart';
import 'package:techstax_assign/services/supabase_services.dart';
import 'package:techstax_assign/utils/validator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Task> _tasks = [];
  bool _isLoading = true;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fetchTasks();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await _supabaseService.getTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load tasks');
    }
  }

  Future<void> _addTask(String title) async {
    try {
      await _supabaseService.addTask(title);
      await _fetchTasks();
    } catch (e) {
      _showErrorSnackBar('Failed to add task');
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _supabaseService.deleteTask(taskId);
      setState(() {
        _tasks.removeWhere((task) => task.id == taskId);
      });
    } catch (e) {
      _showErrorSnackBar('Failed to delete task');
      await _fetchTasks(); // Refresh to ensure UI is in sync with backend
    }
  }

  Future<void> _toggleTaskComplete(String taskId, bool isComplete) async {
    try {
      await _supabaseService.toggleTaskComplete(taskId, isComplete);
      setState(() {
        final index = _tasks.indexWhere((task) => task.id == taskId);
        if (index != -1) {
          _tasks[index] = _tasks[index].copyWith(isComplete: isComplete);
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to update task');
      await _fetchTasks(); // Refresh to ensure UI is in sync with backend
    }
  }

  void _showAddTaskDialog() {
    final taskController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add New Task',
                    style: AppTheme.subheadingStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: taskController,
                    decoration: AppTheme.inputDecoration('Task Name'),
                    validator: Validators.validateTaskName,
                    maxLines: 2,
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        _addTask(taskController.text.trim());
                      }
                    },
                    child: const Text('Add Task'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _signOut() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _tasks.isEmpty
              ? _buildEmptyState()
              : _buildTaskList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.task_alt,
            size: 80,
            color: AppTheme.lightTextColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Tasks Yet',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first task',
            style: AppTheme.captionStyle,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddTaskDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _tasks.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index, animation) {
        final task = _tasks[index];
        return TaskTile(
          task: task,
          onDelete: _deleteTask,
          onToggleComplete: _toggleTaskComplete,
          animation: animation,
        );
      },
    );
  }
}
