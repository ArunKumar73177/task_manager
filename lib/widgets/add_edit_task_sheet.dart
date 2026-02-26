import 'package:flutter/material.dart';

// ─── Task Model ───────────────────────────────────────────────────────────────

class Task {
  final String id;
  final String title;
  final String description;
  final String status; // 'pending' or 'completed'
  final DateTime? dueDate;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.dueDate,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

// ─── Add / Edit Task Bottom Sheet ─────────────────────────────────────────────

class AddEditTaskSheet extends StatefulWidget {
  final Task? task;           // null = Add mode, non-null = Edit mode
  final void Function(Task task) onSave;

  const AddEditTaskSheet({
    super.key,
    this.task,
    required this.onSave,
  });

  /// Helper to open the sheet and await result
  static Future<void> show(
      BuildContext context, {
        Task? task,
        required void Function(Task task) onSave,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditTaskSheet(task: task, onSave: onSave),
    );
  }

  @override
  State<AddEditTaskSheet> createState() => _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends State<AddEditTaskSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _status = 'pending';
  DateTime? _dueDate;
  bool _isSaving = false;

  // Validation errors
  String? _titleError;
  String? _descError;
  String? _dueDateError;

  bool get _isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _status = widget.task!.status;
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ── Validation ──────────────────────────────────────────────────────────────

  bool _validate() {
    String? titleErr;
    String? descErr;
    String? dateErr;

    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) {
      titleErr = 'Task title is required';
    } else if (title.length < 3) {
      titleErr = 'Task title must be at least 3 characters';
    }

    if (desc.isEmpty) {
      descErr = 'Task description is required';
    } else if (desc.length < 10) {
      descErr = 'Task description must be at least 10 characters';
    }

    if (_dueDate == null) {
      dateErr = 'Due date is required';
    }

    setState(() {
      _titleError = titleErr;
      _descError = descErr;
      _dueDateError = dateErr;
    });

    return titleErr == null && descErr == null && dateErr == null;
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _handleSave() async {
    if (!_validate()) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 400));

    final saved = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      status: _status,
      dueDate: _dueDate,
    );

    if (mounted) {
      widget.onSave(saved);
      Navigator.of(context).pop();
    }
  }

  void _handleCancel() => Navigator.of(context).pop();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6750A4),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dueDateError = null;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Let sheet resize with keyboard
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 12, 0),
            child: Row(
              children: [
                // Drag handle centered above header
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        _isEditMode ? 'Edit Task' : 'Add Task',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1B1F),
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button
                IconButton(
                  onPressed: _handleCancel,
                  icon: const Icon(Icons.close, color: Color(0xFF49454F)),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF3EDF7),
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 24, color: Color(0xFFF0F0F0)),

          // ── Scrollable Form ───────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Task Title
                  _buildLabel('Task Title'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _titleController,
                    hint: 'Enter task title',
                    errorText: _titleError,
                    onChanged: (_) {
                      if (_titleError != null) setState(() => _titleError = null);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Task Description
                  _buildLabel('Task Description'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descController,
                    hint: 'Enter task description',
                    errorText: _descError,
                    maxLines: 4,
                    onChanged: (_) {
                      if (_descError != null) setState(() => _descError = null);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Task Status
                  _buildLabel('Task Status'),
                  const SizedBox(height: 8),
                  _buildStatusSelector(),
                  const SizedBox(height: 20),

                  // Due Date
                  _buildLabel('Due Date'),
                  const SizedBox(height: 8),
                  _buildDatePicker(),
                  if (_dueDateError != null) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        _dueDateError!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Action Buttons ────────────────────────────────────────────────
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Save Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6750A4),
                      disabledBackgroundColor: const Color(0xFFCAC4D0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      _isEditMode ? 'Save Changes' : 'Save Task',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Cancel Button
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _handleCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6750A4),
                      side: const BorderSide(color: Color(0xFF6750A4), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF49454F),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? errorText,
    int maxLines = 1,
    required ValueChanged<String> onChanged,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          textCapitalization: TextCapitalization.sentences,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 16, color: Color(0xFF1C1B1F)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
            filled: true,
            fillColor: const Color(0xFFF7F2FA),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? const Color(0xFFEF4444) : Colors.transparent,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF6750A4),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: ['pending', 'completed'].map((s) {
        final isSelected = _status == s;
        final isPending = s == 'pending';
        final label = isPending ? 'Pending' : 'Completed';
        final activeColor =
        isPending ? const Color(0xFFFF9800) : const Color(0xFF4CAF50);
        final activeBg =
        isPending ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _status = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: isPending ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? activeBg : const Color(0xFFF7F2FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? activeColor : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    size: 16,
                    color: isSelected ? activeColor : const Color(0xFF9E9E9E),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? activeColor : const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    final hasError = _dueDateError != null;
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F2FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasError ? const Color(0xFFEF4444) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: hasError
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF6750A4),
            ),
            const SizedBox(width: 10),
            Text(
              _dueDate != null ? _formatDate(_dueDate!) : 'Pick a date',
              style: TextStyle(
                fontSize: 16,
                color: _dueDate != null
                    ? const Color(0xFF1C1B1F)
                    : const Color(0xFF9E9E9E),
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }
}