import 'package:flutter/material.dart';
import 'package:techstax_assign/app/theme.dart';
import 'package:techstax_assign/dashboard/task_model.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(String) onDelete;
  final Function(String, bool) onToggleComplete;
  final Animation<double> animation;

  const TaskTile({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggleComplete,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Dismissible(
          key: Key(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppTheme.errorColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (_) => onDelete(task.id),
          child: Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Checkbox(
                value: task.isComplete,
                activeColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (value) {
                  if (value != null) {
                    onToggleComplete(task.id, value);
                  }
                },
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: task.isComplete
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: task.isComplete
                      ? AppTheme.lightTextColor
                      : AppTheme.textColor,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Created: ${DateFormat('MMM d, yyyy').format(task.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.lightTextColor,
                  ),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppTheme.lightTextColor),
                onPressed: () => onDelete(task.id),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
