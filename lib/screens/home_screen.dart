import 'package:flutter/material.dart';
import 'dart:math';

// ─── Task Model ───────────────────────────────────────────────────────────────

class Task {
  final String id;
  final String title;
  final String status; // 'Pending' or 'Completed'
  final DateTime dueDate;

  const Task({
    required this.id,
    required this.title,
    required this.status,
    required this.dueDate,
  });
}

// ─── Mock Data ────────────────────────────────────────────────────────────────

final List<Task> mockTasks = [
  Task(id: '1', title: 'Complete project proposal', status: 'Pending',   dueDate: DateTime(2026, 3, 28)),
  Task(id: '2', title: 'Review design mockups',     status: 'Completed', dueDate: DateTime(2026, 3, 25)),
  Task(id: '3', title: 'Update documentation',      status: 'Pending',   dueDate: DateTime(2026, 3, 27)),
  Task(id: '4', title: 'Schedule team meeting',     status: 'Pending',   dueDate: DateTime(2026, 3, 29)),
  Task(id: '5', title: 'Fix reported bugs',         status: 'Completed', dueDate: DateTime(2026, 3, 24)),
];

// ─── TaskCard Widget ──────────────────────────────────────────────────────────

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'Completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: isCompleted ? const Color(0xFF9E9E9E) : const Color(0xFF1C1B1F),
                decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                decorationColor: const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                    ),
                  ),
                ),
                Text(
                  'Due: ${_formatDate(task.dueDate)}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Task Bottom Sheet ────────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  final void Function(Task task) onTaskAdded;

  const _AddTaskSheet({required this.onTaskAdded});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedStatus = 'Pending';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _titleError = '';
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6750A4),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Task title is required');
      return;
    }
    setState(() {
      _titleError = '';
      _isSaving = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      status: _selectedStatus,
      dueDate: _selectedDate,
    );

    if (mounted) {
      widget.onTaskAdded(newTask);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Add New Task',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1B1F),
            ),
          ),
          const SizedBox(height: 24),

          // Task Title Field
          const Text(
            'Task Title',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF49454F),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) {
              if (_titleError.isNotEmpty) setState(() => _titleError = '');
            },
            style: const TextStyle(fontSize: 16, color: Color(0xFF1C1B1F)),
            decoration: InputDecoration(
              hintText: 'e.g. Review quarterly report',
              hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
              filled: true,
              fillColor: const Color(0xFFF7F2FA),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              errorText: _titleError.isNotEmpty ? _titleError : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _titleError.isNotEmpty ? const Color(0xFFEF4444) : Colors.transparent,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _titleError.isNotEmpty ? const Color(0xFFEF4444) : const Color(0xFF6750A4),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Status Selector
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF49454F),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Pending', 'Completed'].map((status) {
              final isSelected = _selectedStatus == status;
              final isPending = status == 'Pending';
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedStatus = status),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: isPending ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isPending ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9))
                          : const Color(0xFFF7F2FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? (isPending ? const Color(0xFFFF9800) : const Color(0xFF4CAF50))
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          size: 16,
                          color: isSelected
                              ? (isPending ? const Color(0xFFFF9800) : const Color(0xFF4CAF50))
                              : const Color(0xFF9E9E9E),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? (isPending ? const Color(0xFFFF9800) : const Color(0xFF4CAF50))
                                : const Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Due Date Picker
          const Text(
            'Due Date',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF49454F),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF6750A4)),
                  const SizedBox(width: 10),
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(fontSize: 16, color: Color(0xFF1C1B1F)),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6750A4),
                disabledBackgroundColor: const Color(0xFFCAC4D0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
                  : const Text(
                'Add Task',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
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
  List<Task> _tasks = [];
  bool _loading = true;
  bool _error = false;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    final shouldSucceed = Random().nextDouble() > 0.2;

    if (shouldSucceed) {
      setState(() {
        _tasks = List.from(mockTasks);
        _loading = false;
      });
    } else {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _refreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    final shuffled = List<Task>.from(_tasks)..shuffle();
    setState(() {
      _tasks = shuffled;
      _refreshing = false;
    });
  }

  void _handleAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskSheet(
        onTaskAdded: (newTask) {
          setState(() => _tasks.insert(0, newTask));
        },
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF6750A4)),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6750A4),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
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
      body: _buildBody(),
      floatingActionButton: (!_loading && !_error)
          ? FloatingActionButton(
        onPressed: _handleAddTask,
        backgroundColor: const Color(0xFF6750A4),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6750A4), strokeWidth: 3),
      );
    }

    if (_error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFF9E9E9E)),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF9E9E9E)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unable to load tasks. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadTasks,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_tasks.isEmpty) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.task_outlined, size: 48, color: Color(0xFF9E9E9E)),
                SizedBox(height: 12),
                Text(
                  'No tasks available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF9E9E9E)),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first task',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
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
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_refreshing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF6750A4), strokeWidth: 2),
                    ),
                  ),
                ..._tasks.map((task) => TaskCard(key: ValueKey(task.id), task: task)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}