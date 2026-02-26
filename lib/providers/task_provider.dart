import 'package:flutter/foundation.dart';

import '../services/task_api_service.dart';
import '../widgets/add_edit_task_sheet.dart'; // Task model

// ─────────────────────────────────────────────────────────────────────────────
// task_provider.dart
//
// Sits between the UI and TaskApiService.
// The UI never touches the service directly — it only calls provider methods
// and reacts to state changes via context.watch / Consumer.
//
// Data flow:
//   UI  →  TaskProvider  →  TaskApiService  →  ApiResponse<T>
//                ↑                                    |
//                └──────── notifyListeners() ─────────┘
// ─────────────────────────────────────────────────────────────────────────────

// ─── TaskStatus ───────────────────────────────────────────────────────────────

/// Every possible state the task list can be in.
/// An enum eliminates impossible boolean combinations (e.g. loading + error).
enum TaskStatus { initial, loading, loaded, error }

// ─── TaskProvider ─────────────────────────────────────────────────────────────

class TaskProvider extends ChangeNotifier {
  // ── Dependencies ───────────────────────────────────────────────────────────

  /// Injected service — swap for a real HTTP implementation without touching
  /// this class or any UI code.
  final TaskApiService _api;

  TaskProvider({TaskApiService? api}) : _api = api ?? TaskApiService();

  // ── Private state ──────────────────────────────────────────────────────────

  List<Task> _tasks = [];
  TaskStatus _status = TaskStatus.initial;
  String? _errorMessage;

  // ── Public getters ─────────────────────────────────────────────────────────

  /// Unmodifiable snapshot — consumers cannot mutate the list directly.
  List<Task> get tasks => List.unmodifiable(_tasks);

  TaskStatus get status => _status;
  String? get errorMessage => _errorMessage;

  // Convenience booleans for cleaner UI switch/if logic
  bool get isLoading => _status == TaskStatus.loading;
  bool get hasError => _status == TaskStatus.error;
  bool get isLoaded => _status == TaskStatus.loaded;
  bool get isEmpty => _tasks.isEmpty;

  // Derived counts — useful for badges / summary widgets
  int get totalCount => _tasks.length;
  int get pendingCount => _tasks.where((t) => t.status == 'pending').length;
  int get completedCount => _tasks.where((t) => t.status == 'completed').length;

  // ── Public API — mirror TaskApiService endpoints ───────────────────────────

  /// Fetches all tasks from the service layer.
  ///
  /// Maps to: GET /tasks
  Future<void> fetchTasks() async {
    _setLoading();

    try {
      final response = await _api.getTasks();

      if (response.isSuccess && response.data != null) {
        _tasks = response.data!;
        _setLoaded();
      } else {
        _setError(response.error ?? 'Failed to load tasks.');
      }
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      debugPrint('[TaskProvider.fetchTasks] $e');
    }
  }

  /// Creates a new task and inserts it at the top of the list on success.
  ///
  /// Maps to: POST /tasks
  /// Returns `true` on success, `false` on failure (caller can show a snackbar).
  Future<bool> addTask(Task task) async {
    _assertLoaded('addTask');

    try {
      final response = await _api.createTask(task);

      if (response.isSuccess && response.data != null) {
        _tasks = [response.data!, ..._tasks];
        notifyListeners();
        return true;
      } else {
        debugPrint('[TaskProvider.addTask] ${response.error}');
        return false;
      }
    } on ApiException catch (e) {
      debugPrint('[TaskProvider.addTask] ApiException: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[TaskProvider.addTask] $e');
      return false;
    }
  }

  /// Replaces a task in the list with the updated version on success.
  ///
  /// Maps to: PUT /tasks/:id
  /// Returns `true` on success, `false` on failure.
  Future<bool> updateTask(Task task) async {
    _assertLoaded('updateTask');

    // Optimistic update — apply immediately, roll back on failure
    final previousTasks = List<Task>.from(_tasks);
    final index = _tasks.indexWhere((t) => t.id == task.id);

    if (index == -1) {
      debugPrint('[TaskProvider.updateTask] task "${task.id}" not found.');
      return false;
    }

    // Apply optimistically
    final optimistic = List<Task>.from(_tasks);
    optimistic[index] = task;
    _tasks = optimistic;
    notifyListeners();

    try {
      final response = await _api.updateTask(task);

      if (response.isSuccess && response.data != null) {
        // Confirm with server-returned data (may differ slightly)
        final confirmed = List<Task>.from(_tasks);
        confirmed[index] = response.data!;
        _tasks = confirmed;
        notifyListeners();
        return true;
      } else {
        // Roll back
        _tasks = previousTasks;
        notifyListeners();
        debugPrint('[TaskProvider.updateTask] ${response.error}');
        return false;
      }
    } on ApiException catch (e) {
      _tasks = previousTasks;
      notifyListeners();
      debugPrint('[TaskProvider.updateTask] ApiException: ${e.message}');
      return false;
    } catch (e) {
      _tasks = previousTasks;
      notifyListeners();
      debugPrint('[TaskProvider.updateTask] $e');
      return false;
    }
  }

  /// Removes a task from the list on success.
  ///
  /// Maps to: DELETE /tasks/:id
  /// Returns `true` on success, `false` on failure.
  Future<bool> deleteTask(String id) async {
    _assertLoaded('deleteTask');

    // Optimistic removal
    final previousTasks = List<Task>.from(_tasks);
    _tasks = _tasks.where((t) => t.id != id).toList();
    notifyListeners();

    try {
      final response = await _api.deleteTask(id);

      if (response.isSuccess) {
        return true;
      } else {
        // Roll back
        _tasks = previousTasks;
        notifyListeners();
        debugPrint('[TaskProvider.deleteTask] ${response.error}');
        return false;
      }
    } on ApiException catch (e) {
      _tasks = previousTasks;
      notifyListeners();
      debugPrint('[TaskProvider.deleteTask] ApiException: ${e.message}');
      return false;
    } catch (e) {
      _tasks = previousTasks;
      notifyListeners();
      debugPrint('[TaskProvider.deleteTask] $e');
      return false;
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _setLoading() {
    _status = TaskStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoaded() {
    _status = TaskStatus.loaded;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = TaskStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// Guards mutation methods against being called before data has been fetched.
  void _assertLoaded(String methodName) {
    if (_status != TaskStatus.loaded) {
      throw StateError(
        '[TaskProvider] Cannot call "$methodName" before tasks are loaded. '
            'Ensure fetchTasks() completes successfully first.',
      );
    }
  }
}