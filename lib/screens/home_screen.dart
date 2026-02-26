import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../widgets/add_edit_task_sheet.dart';

// ─── TaskCard ─────────────────────────────────────────────────────────────────

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: isCompleted
                              ? const Color(0xFF9E9E9E)
                              : const Color(0xFF1C1B1F),
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: const Color(0xFF9E9E9E),
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9E9E9E),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  onTap: onEdit,
                  backgroundColor: const Color(0xFFF3EDF7),
                  icon: Icons.edit_outlined,
                  iconColor: const Color(0xFF6750A4),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  onTap: onDelete,
                  backgroundColor: const Color(0xFFFFEBEE),
                  icon: Icons.delete_outline_rounded,
                  iconColor: const Color(0xFFE53935),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCompleted ? 'Completed' : 'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isCompleted
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800),
                    ),
                  ),
                ),
                if (task.dueDate != null)
                  Text(
                    'Due: ${_formatDate(task.dueDate!)}',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF9E9E9E)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _ActionButton ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;

  const _ActionButton({
    required this.onTap,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

// ─── _SnackbarHelper ──────────────────────────────────────────────────────────
// FIX: Removed the `context.mounted` check from inside these methods.
// The caller is responsible for checking `mounted` before calling these —
// that's the correct pattern that satisfies the linter's async-gap rule.
// These methods are only ever called synchronously after a mounted check
// at the call site, so it is safe.

class _SnackbarHelper {
  // FIX: SnackBarBehavior (capital B) — was incorrectly written as
  // SnackbarBehavior (lowercase b) which is an undefined name.

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating, // FIX: capital B
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating, // FIX: capital B
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

// ─── HomeScreen ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _handleRefresh() async {
    await context.read<TaskProvider>().fetchTasks();
  }

  void _handleAddTask() {
    AddEditTaskSheet.show(
      context,
      onSave: (newTask) async {
        final provider = context.read<TaskProvider>();
        final ok = await provider.addTask(newTask);
        // FIX: mounted check at the call site — not inside the helper.
        // This is what the linter requires for async-gap safety.
        if (!mounted) return;
        if (ok) {
          _SnackbarHelper.showSuccess(context, 'Task added successfully.');
        } else {
          _SnackbarHelper.showError(
              context, 'Failed to add task. Please try again.');
        }
      },
    );
  }

  void _handleEditTask(Task task) {
    AddEditTaskSheet.show(
      context,
      task: task,
      onSave: (updated) async {
        final provider = context.read<TaskProvider>();
        final ok = await provider.updateTask(updated);
        // FIX: mounted check at the call site
        if (!mounted) return;
        if (ok) {
          _SnackbarHelper.showSuccess(context, 'Task updated successfully.');
        } else {
          _SnackbarHelper.showError(
              context, 'Failed to update task. Please try again.');
        }
      },
    );
  }

  void _handleDeleteTask(BuildContext context, Task task) {
    showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFFFFEBEE),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: Color(0xFFE53935), size: 26),
        ),
        title: const Text(
          'Delete Task',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1B1F),
          ),
        ),
        content: Text(
          'Are you sure you want to delete\n"${task.title}"?\n\nThis action cannot be undone.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF49454F),
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        actions: [
          SizedBox(
            height: 44,
            width: 120,
            child: OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6750A4),
                side: const BorderSide(
                    color: Color(0xFF6750A4), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 44,
            width: 120,
            child: ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Delete',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      // FIX: mounted check at the call site before any context usage
      if (!mounted) return;
      final provider = context.read<TaskProvider>();
      final ok = await provider.deleteTask(task.id);
      // FIX: second mounted check after the await
      if (!mounted) return;
      if (!ok) {
        _SnackbarHelper.showError(
            context, 'Failed to delete task. Please try again.');
      }
    });
  }

  void _handleLogout() {
    showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFFF3EDF7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout_rounded,
              color: Color(0xFF6750A4), size: 26),
        ),
        title: const Text(
          'Logout',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1B1F),
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?\nYou will need to login again.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF49454F),
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        actions: [
          SizedBox(
            height: 44,
            width: 120,
            child: OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6750A4),
                side: const BorderSide(
                    color: Color(0xFF6750A4), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 44,
            width: 120,
            child: ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6750A4),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Logout',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      // FIX: mounted check at the call site before using context
      if (!mounted) return;
      final authService = context.read<AuthService>();
      await authService.clearToken();
      // FIX: second mounted check after the await
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
      );
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6750A4),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        title: const Text(
          'My Tasks',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(provider),
      floatingActionButton: provider.isLoaded
          ? FloatingActionButton(
        onPressed: _handleAddTask,
        backgroundColor: const Color(0xFF6750A4),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  // ── Body builder ──────────────────────────────────────────────────────────

  Widget _buildBody(TaskProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6750A4),
          strokeWidth: 3,
        ),
      );
    }

    if (provider.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Color(0xFF9E9E9E)),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage ??
                    'Unable to load tasks. Please try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF9E9E9E)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<TaskProvider>().fetchTasks(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.task_outlined,
                  size: 48, color: Color(0xFF9E9E9E)),
              SizedBox(height: 12),
              Text(
                'No tasks available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tap the + button to add your first task',
                textAlign: TextAlign.center,
                style:
                TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFF6750A4),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ...provider.tasks.map(
                      (task) => TaskCard(
                    key: ValueKey(task.id),
                    task: task,
                    onEdit: () => _handleEditTask(task),
                    onDelete: () => _handleDeleteTask(context, task),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}