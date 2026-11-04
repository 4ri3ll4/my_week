import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseState extends ChangeNotifier {
    CourseState(this._repo) {
        _subscription = _repo.watchAll().listen(
                (list) {
                        _courses = list;
        _loading = false;
        _error = null;
        notifyListeners();
      },
        onError: (Object e) {
            _loading = false;
            _error = 'Could not load your courses.';
            notifyListeners();
        },
    );
    }

    final CourseRepository _repo;
    StreamSubscription<List<Course>>? _subscription;

    // Private data: only the brain can change it.
    List<Course> _courses = [];
    bool _loading = true;
    String? _error;
    int _selectedDay = 0;
    String _query = '';

    // Read-only views.
    List<Course> get courses => _courses;
    bool get loading => _loading;
    String? get error => _error;
    int get selectedDay => _selectedDay;

    // Computed: never stored, worked out every read. Habit 2.
    int get weekMinutes =>
            _courses.fold(0, (sum, c) => sum + c.durationMinutes);

    List<Course> get dayCourses {
        final list = _courses.where((c) => c.day == _selectedDay).toList();
        list.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
        return list;
    }

    List<Course> get visibleCourses {
        final list = dayCourses;
        if (_query.isEmpty) return list;
        return list
                .where((c) => c.name.toLowerCase().contains(_query))
                .toList();
    }

    int get dayMinutes =>
            dayCourses.fold(0, (sum, c) => sum + c.durationMinutes);

    // Actions: change private data, then notify.
    void setDay(int day) {
        _selectedDay = day;
        notifyListeners();
    }

    void setQuery(String value) {
        _query = value.toLowerCase().trim();
        notifyListeners();
    }

    Future<void> add(Course course) => _repo.add(course);
    Future<void> edit(String id, Course course) => _repo.update(id, course);
    Future<void> remove(Course course) => _repo.delete(course.id);

    @override
    void dispose() {
        _subscription?.cancel();
        super.dispose();
    }
}