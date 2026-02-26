import 'dart:math';
import '../widgets/add_edit_task_sheet.dart'; // Task model

// ─────────────────────────────────────────────────────────────────────────────
// task_api_service.dart
//
// A mock REST-style API layer that simulates real network behaviour:
//   • Realistic latency via Future.delayed
//   • Random failure rate (~15 %) to exercise error handling
//   • Typed ApiResponse<T> wrapper mirroring HTTP status codes
//   • Endpoint-per-method pattern (GET / POST / PUT / DELETE)
//
// Usage:
//   final api = TaskApiService();
//   final response = await api.getTasks();
//   if (response.isSuccess) { ... response.data ... }
//
// To swap in a real backend later, replace only the method bodies — the
// contract (ApiResponse, method signatures) stays identical.
// ─────────────────────────────────────────────────────────────────────────────

// ─── Network simulation constants ────────────────────────────────────────────

/// Base simulated latency.  Individual endpoints add jitter on top of this.
const Duration _kBaseLatency = Duration(milliseconds: 800);

/// Probability that any given request fails (0.0 – 1.0).
const double _kFailureRate = 0.15;

// ─── ApiResponse<T> ───────────────────────────────────────────────────────────

/// Typed wrapper that mirrors a real HTTP response.
///
/// [statusCode] follows standard HTTP conventions:
///   200 OK · 201 Created · 204 No Content · 400 Bad Request ·
///   404 Not Found · 500 Internal Server Error
class ApiResponse<T> {
  final int statusCode;
  final T? data;
  final String? error;

  const ApiResponse._({
    required this.statusCode,
    this.data,
    this.error,
  });

  // ── Named constructors ────────────────────────────────────────────────────

  /// 200 OK — successful fetch.
  const ApiResponse.ok(T data)
      : this._(statusCode: 200, data: data);

  /// 201 Created — resource created successfully.
  const ApiResponse.created(T data)
      : this._(statusCode: 201, data: data);

  /// 204 No Content — action succeeded with no body (e.g. delete).
  const ApiResponse.noContent()
      : this._(statusCode: 204);

  /// 400 Bad Request — invalid input.
  const ApiResponse.badRequest(String message)
      : this._(statusCode: 400, error: message);

  /// 404 Not Found — resource does not exist.
  const ApiResponse.notFound(String message)
      : this._(statusCode: 404, error: message);

  /// 500 Internal Server Error — simulated server crash.
  const ApiResponse.serverError([String message = 'Internal server error'])
      : this._(statusCode: 500, error: message);

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;

  @override
  String toString() =>
      'ApiResponse(statusCode: $statusCode, '
          'data: $data, error: $error)';
}

// ─── ApiException ─────────────────────────────────────────────────────────────

/// Thrown for unexpected failures (e.g. simulated connectivity loss).
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ─── Mock seed data ───────────────────────────────────────────────────────────

final List<Map<String, dynamic>> _kSeedJson = [
  {
    'id': '1',
    'title': 'Complete project proposal',
    'description':
    'Write comprehensive proposal covering all project requirements and timelines',
    'status': 'pending',
    'due_date': '2026-03-28',
  },
  {
    'id': '2',
    'title': 'Review design mockups',
    'description':
    'Go through all the latest design mockups and provide detailed feedback',
    'status': 'completed',
    'due_date': '2026-03-25',
  },
  {
    'id': '3',
    'title': 'Update documentation',
    'description':
    'Update all outdated sections in the developer documentation portal',
    'status': 'pending',
    'due_date': '2026-03-27',
  },
  {
    'id': '4',
    'title': 'Schedule team meeting',
    'description':
    'Set up a recurring weekly sync with all team leads to discuss progress',
    'status': 'pending',
    'due_date': '2026-03-29',
  },
  {
    'id': '5',
    'title': 'Fix reported bugs',
    'description':
    'Address all critical bugs reported in the latest QA cycle before release',
    'status': 'completed',
    'due_date': '2026-03-24',
  },
];

// ─── TaskApiService ───────────────────────────────────────────────────────────

/// Stateless mock service.  Every public method maps to a REST endpoint:
///
///   getTasks()            →  GET    /tasks
///   getTaskById(id)       →  GET    /tasks/:id
///   createTask(task)      →  POST   /tasks
///   updateTask(task)      →  PUT    /tasks/:id
///   deleteTask(id)        →  DELETE /tasks/:id
class TaskApiService {
  // In-memory "database" — initialised from seed JSON, mutated by write ops.
  final List<Map<String, dynamic>> _db =
  _kSeedJson.map((e) => Map<String, dynamic>.from(e)).toList();

  final Random _rng = Random();

  // ── GET /tasks ─────────────────────────────────────────────────────────────

  /// Fetches the full task list.
  ///
  /// Simulates: GET /api/v1/tasks
  Future<ApiResponse<List<Task>>> getTasks() async {
    await _simulateLatency(extra: const Duration(milliseconds: 300));
    _maybeThrow('GET /tasks');

    final tasks = _db.map(_taskFromJson).toList();
    return ApiResponse.ok(tasks);
  }

  // ── GET /tasks/:id ────────────────────────────────────────────────────────

  /// Fetches a single task by its ID.
  ///
  /// Returns [ApiResponse.notFound] when the ID doesn't exist.
  ///
  /// Simulates: GET /api/v1/tasks/:id
  Future<ApiResponse<Task>> getTaskById(String id) async {
    await _simulateLatency();
    _maybeThrow('GET /tasks/$id');

    final json = _findById(id);
    if (json == null) {
      return ApiResponse.notFound('Task with id "$id" not found.');
    }

    return ApiResponse.ok(_taskFromJson(json));
  }

  // ── POST /tasks ───────────────────────────────────────────────────────────

  /// Creates a new task.
  ///
  /// Validates [task.title] and [task.description] before persisting.
  /// Returns [ApiResponse.created] with the saved task on success.
  ///
  /// Simulates: POST /api/v1/tasks
  Future<ApiResponse<Task>> createTask(Task task) async {
    await _simulateLatency(extra: const Duration(milliseconds: 200));
    _maybeThrow('POST /tasks');

    // Basic server-side validation
    if (task.title.trim().isEmpty) {
      return const ApiResponse.badRequest('title is required.');
    }
    if (task.description.trim().length < 10) {
      return const ApiResponse.badRequest(
          'description must be at least 10 characters.');
    }

    final newJson = _taskToJson(task);
    _db.insert(0, newJson);

    return ApiResponse.created(_taskFromJson(newJson));
  }

  // ── PUT /tasks/:id ────────────────────────────────────────────────────────

  /// Fully replaces an existing task.
  ///
  /// Returns [ApiResponse.notFound] when the ID doesn't exist.
  ///
  /// Simulates: PUT /api/v1/tasks/:id
  Future<ApiResponse<Task>> updateTask(Task task) async {
    await _simulateLatency(extra: const Duration(milliseconds: 100));
    _maybeThrow('PUT /tasks/${task.id}');

    final index = _db.indexWhere((e) => e['id'] == task.id);
    if (index == -1) {
      return ApiResponse.notFound('Task with id "${task.id}" not found.');
    }

    final updatedJson = _taskToJson(task);
    _db[index] = updatedJson;

    return ApiResponse.ok(_taskFromJson(updatedJson));
  }

  // ── DELETE /tasks/:id ─────────────────────────────────────────────────────

  /// Removes a task permanently.
  ///
  /// Returns [ApiResponse.notFound] when the ID doesn't exist.
  /// Returns [ApiResponse.noContent] (204) on success — no body.
  ///
  /// Simulates: DELETE /api/v1/tasks/:id
  Future<ApiResponse<void>> deleteTask(String id) async {
    await _simulateLatency();
    _maybeThrow('DELETE /tasks/$id');

    final index = _db.indexWhere((e) => e['id'] == id);
    if (index == -1) {
      return ApiResponse.notFound('Task with id "$id" not found.');
    }

    _db.removeAt(index);
    return const ApiResponse.noContent();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Pauses execution to mimic real network round-trip time.
  /// [extra] adds endpoint-specific jitter on top of [_kBaseLatency].
  Future<void> _simulateLatency({Duration extra = Duration.zero}) {
    final jitter = _rng.nextInt(300); // 0–299 ms random jitter
    final total = _kBaseLatency + extra + Duration(milliseconds: jitter);
    return Future.delayed(total);
  }

  /// Randomly throws an [ApiException] to simulate server failures.
  /// Only fires when the random value falls within [_kFailureRate].
  void _maybeThrow(String endpoint) {
    if (_rng.nextDouble() < _kFailureRate) {
      throw ApiException(
        statusCode: 500,
        message: 'Simulated server error on $endpoint. Please retry.',
      );
    }
  }

  /// Finds a raw JSON map by [id], or returns null.
  Map<String, dynamic>? _findById(String id) {
    try {
      return _db.firstWhere((e) => e['id'] == id);
    } catch (_) {
      return null;
    }
  }

  // ── Serialisation ──────────────────────────────────────────────────────────

  /// Deserialises a raw JSON map → [Task].
  Task _taskFromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String)
          : null,
    );
  }

  /// Serialises a [Task] → raw JSON map.
  Map<String, dynamic> _taskToJson(Task task) {
    return {
      'id': task.id,
      'title': task.title.trim(),
      'description': task.description.trim(),
      'status': task.status,
      'due_date': task.dueDate?.toIso8601String().split('T').first,
    };
  }
}