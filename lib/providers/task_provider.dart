import 'package:flutter/foundation.dart';

import '../services/task_api_service.dart';
import '../widgets/add_edit_task_sheet.dart';

// ─── TaskStatus ───────────────────────────────────────────────────────────────

enum TaskStatus { initial, loading, loaded, error }

// ─── TaskProvider ─────────────────────────────────────────────────────────────

class TaskProvider extends ChangeNotifier {
  // ── Dependencies ───────────────────────────────────────────────────────────

  final TaskApiService _api;

  TaskProvider({TaskApiService? api}) : _api = api ?? TaskApiService();

  // ── Private state ──────────────────────────────────────────────────────────

  List<Task> _tasks = [];
  TaskStatus _status = TaskStatus.initial;
  String? _errorMessage;

  // ── Improvement 1: Per-operation loading flags ─────────────────────────────
  // These let the UI show a spinner on the Save button during add/update and
  // block double-taps — without triggering a full-screen loading state.
  bool _isSavingTask = false;
  bool _isDeletingTask = false;

  // ── Public getters ─────────────────────────────────────────────────────────

  List<Task> get tasks => List.unmodifiable(_tasks);
  TaskStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == TaskStatus.loading;
  bool get hasError => _status == TaskStatus.error;
  bool get isLoaded => _status == TaskStatus.loaded;
  bool get isEmpty => _tasks.isEmpty;

  // ── Improvement 1 getters ──────────────────────────────────────────────────
  bool get isSavingTask => _isSavingTask;
  bool get isDeletingTask => _isDeletingTask;

  // Derived counts
  int get totalCount => _tasks.length;
  int get pendingCount => _tasks.where((t) => t.status == 'pending').length;
  int get completedCount => _tasks.where((t) => t.status == 'completed').length;

  // ── fetchTasks ─────────────────────────────────────────────────────────────

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

  // ── addTask ────────────────────────────────────────────────────────────────
  // Improvement 1: sets _isSavingTask so the sheet's Save button can show
  // a spinner. Returns bool so the caller can show a snackbar on failure.

  Future<bool> addTask(Task task) async {
    _assertLoaded('addTask');

    _isSavingTask = true;
    notifyListeners();

    try {
      final response = await _api.createTask(task);
      if (response.isSuccess && response.data != null) {
        _tasks = [response.data!, ..._tasks];
        return true;
      }
      debugPrint('[TaskProvider.addTask] ${response.error}');
      return false;
    } on ApiException catch (e) {
      debugPrint('[TaskProvider.addTask] ApiException: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[TaskProvider.addTask] $e');
      return false;
    } finally {
      // Always clear the flag and notify — even on error
      _isSavingTask = false;
      notifyListeners();
    }
  }

  // ── updateTask ─────────────────────────────────────────────────────────────
  // Optimistic update: apply immediately, roll back on failure.
  // Improvement 1: sets _isSavingTask during the API call.

  Future<bool> updateTask(Task task) async {
    _assertLoaded('updateTask');

    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      debugPrint('[TaskProvider.updateTask] task "${task.id}" not found.');
      return false;
    }

    final previousTasks = List<Task>.from(_tasks);
    final optimistic = List<Task>.from(_tasks)..[index] = task;
    _tasks = optimistic;
    _isSavingTask = true;
    notifyListeners();

    try {
      final response = await _api.updateTask(task);
      if (response.isSuccess && response.data != null) {
        final confirmed = List<Task>.from(_tasks)..[index] = response.data!;
        _tasks = confirmed;
        return true;
      }
      _tasks = previousTasks; // roll back
      debugPrint('[TaskProvider.updateTask] ${response.error}');
      return false;
    } on ApiException catch (e) {
      _tasks = previousTasks;
      debugPrint('[TaskProvider.updateTask] ApiException: ${e.message}');
      return false;
    } catch (e) {
      _tasks = previousTasks;
      debugPrint('[TaskProvider.updateTask] $e');
      return false;
    } finally {
      _isSavingTask = false;
      notifyListeners();
    }
  }

  // ── deleteTask ─────────────────────────────────────────────────────────────
  // Optimistic removal with rollback.
  // Improvement 1: sets _isDeletingTask so the dialog button can show a
  // spinner during the API call.

  Future<bool> deleteTask(String id) async {
    _assertLoaded('deleteTask');

    final previousTasks = List<Task>.from(_tasks);
    _tasks = _tasks.where((t) => t.id != id).toList();
    _isDeletingTask = true;
    notifyListeners();

    try {
      final response = await _api.deleteTask(id);
      if (response.isSuccess) {
        return true;
      }
      _tasks = previousTasks; // roll back
      debugPrint('[TaskProvider.deleteTask] ${response.error}');
      return false;
    } on ApiException catch (e) {
      _tasks = previousTasks;
      debugPrint('[TaskProvider.deleteTask] ApiException: ${e.message}');
      return false;
    } catch (e) {
      _tasks = previousTasks;
      debugPrint('[TaskProvider.deleteTask] $e');
      return false;
    } finally {
      _isDeletingTask = false;
      notifyListeners();
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

  void _assertLoaded(String methodName) {
    if (_status != TaskStatus.loaded) {
      throw StateError(
        '[TaskProvider] Cannot call "$methodName" before tasks are loaded.',
      );
    }
  }
}