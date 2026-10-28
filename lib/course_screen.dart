import 'package:flutter/material.dart';

import 'course.dart';

/// What the screen returns when it pops.
/// Either a saved (new or edited) course, or a "deleted" signal.
class CourseScreenResult {
  const CourseScreenResult.saved(this.course) : deleted = false;
  const CourseScreenResult.deleted()
      : course = null,
        deleted = true;

  final Course? course;
  final bool deleted;
}

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key, this.course});

  /// null → adding a new course. Non-null → editing this one.
  final Course? course;

  bool get isEditing => course != null;

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final nameController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();
  int day = 0;

  static const dayFullNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    if (c != null) {
      nameController.text = c.name;
      startController.text = formatTime(c.startMinutes);
      endController.text = formatTime(c.endMinutes);
      day = c.day;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    startController.dispose();
    endController.dispose();
    super.dispose();
  }

  void save() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      showError('Enter a course name');
      return;
    }

    final start = parseTime(startController.text);
    if (start == null) {
      showError('Start time must be HH:MM, like 08:00');
      return;
    }

    final end = parseTime(endController.text);
    if (end == null) {
      showError('End time must be HH:MM, like 10:00');
      return;
    }

    if (end <= start) {
      showError('End time must be after start time');
      return;
    }

    final result = Course(
      name: name,
      day: day,
      startMinutes: start,
      endMinutes: end,
    );
    Navigator.pop(context, CourseScreenResult.saved(result));
  }

  void delete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this course?'),
        content: Text('"${widget.course?.name}" will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close dialog
              Navigator.pop(context, const CourseScreenResult.deleted());
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit course' : 'Add course'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete course',
              onPressed: delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Course name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: day,
              decoration: const InputDecoration(
                labelText: 'Day',
                border: OutlineInputBorder(),
              ),
              items: [
                for (int i = 0; i < dayFullNames.length; i++)
                  DropdownMenuItem(value: i, child: Text(dayFullNames[i])),
              ],
              onChanged: (v) => setState(() => day = v ?? 0),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startController,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      labelText: 'Start',
                      hintText: '08:00',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: endController,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      labelText: 'End',
                      hintText: '10:00',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: save,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}