import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/add_edit_task_sheet.dart';

// ─── Mock Data ────────────────────────────────────────────────────────────────

final List<Task> mockTasks = [
  Task(
    id: '1',
    title: 'Complete project proposal',
    description: 'Write comprehensive proposal covering all project requirements and timelines',
    status: 'pending',
    dueDate: DateTime(2026, 3, 28),
  ),
  Task(
    id: '2',
    title: 'Review design mockups',
    description: 'Go through all the latest design mockups and provide detailed feedback',
    status: 'completed',
    dueDate: DateTime(2026, 3, 25),
  ),
  Task(
    id: '3',
    title: 'Update documentation',
    description: 'Update all outdated sections in the developer documentation portal',
    status: 'pending',
    dueDate: DateTime(2026, 3, 27),
  ),
  Task(
    id: '4',
    title: 'Schedule team meeting',
    description: 'Set up a recurring weekly sync with all team leads to discuss progress',
    status: 'pending',
    dueDate: DateTime(2026, 3, 29),
  ),
  Task(
    id: '5',
    title: 'Fix reported bugs',
    description: 'Address all critical bugs reported in the latest QA cycle before release',
    status: 'completed',
    dueDate: DateTime(2026, 3, 24),
  ),
];

// ─── TaskCard Widget ──────────────────────────────────────────────────────────

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;

  const TaskCard({super.key, required this.task, required this.onEdit});

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
      shadowColor: Colors.black.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row + edit button
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
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3EDF7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF6750A4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status chip + Due date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
              ],
            ),
          ],
        ),
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
    AddEditTaskSheet.show(
      context,
      onSave: (newTask) {
        setState(() => _tasks.insert(0, newTask));
      },
    );
  }

  void _handleEditTask(Task task) {
    AddEditTaskSheet.show(
      context,
      task: task,
      onSave: (updated) {
        setState(() {
          final index = _tasks.indexWhere((t) => t.id == updated.id);
          if (index != -1) _tasks[index] = updated;
        });
      },
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6750A4)),
            child: const Text('Logout',
                style: TextStyle(fontWeight: FontWeight.w600)),
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
        child: CircularProgressIndicator(
            color: Color(0xFF6750A4), strokeWidth: 3),
      );
    }

    if (_error) {
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
                    color: Color(0xFF9E9E9E)),
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

    if (_tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.task_outlined, size: 48, color: Color(0xFF9E9E9E)),
              SizedBox(height: 12),
              Text(
                'No tasks available',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9E9E)),
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
                if (_refreshing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF6750A4), strokeWidth: 2),
                    ),
                  ),
                ..._tasks.map((task) => TaskCard(
                  key: ValueKey(task.id),
                  task: task,
                  onEdit: () => _handleEditTask(task),
                )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}