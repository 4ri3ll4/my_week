import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  Course({
    this.id = '',
    required this.name,
    required this.day,
    required this.startMinutes,
    required this.endMinutes,
  });

  final String id;
  String name;
  int day;
  int startMinutes;
  int endMinutes;

  int get durationMinutes => endMinutes - startMinutes;

  Map<String, dynamic> toMap() => {
    'name': name,
    'day': day,
    'startMinutes': startMinutes,
    'endMinutes': endMinutes,
  };

  factory Course.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Course(
      id: doc.id,
      name: data['name'] as String,
      day: data['day'] as int,
      startMinutes: data['startMinutes'] as int,
      endMinutes: data['endMinutes'] as int,
    );
  }
}

int? parseTime(String text) {
  final parts = text.trim().split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  if (h < 0 || h > 23) return null;
  if (m < 0 || m > 59) return null;
  return h * 60 + m;
}

String formatTime(int minutes) {
  final h = (minutes ~/ 60).toString().padLeft(2, '0');
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

String formatDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

bool clashes(Course a, Course b) {
  if (identical(a, b)) return false;
  if (a.day != b.day) return false;
  return a.startMinutes < b.endMinutes && b.startMinutes < a.endMinutes;
}

List<String> clashNames(Course course, List<Course> all) {
  return all
      .where((other) => clashes(course, other))
      .map((c) => c.name)
      .toList();
}