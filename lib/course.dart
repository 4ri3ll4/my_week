class Course {
  Course({
    required this.name,
    required this.day,
    required this.startMinutes,
    required this.endMinutes,
  });

  String name;
  int day;            // 0 = Monday, 1 = Tuesday, … 4 = Friday
  int startMinutes;   // minutes since midnight, e.g. 480 for 08:00
  int endMinutes;

  int get durationMinutes => endMinutes - startMinutes;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'day': day,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      name: json['name'] as String,
      day: json['day'] as int,
      startMinutes: json['startMinutes'] as int,
      endMinutes: json['endMinutes'] as int,
    );
  }
}

/// Reads "HH:MM" and returns minutes since midnight, or null if invalid.
/// Rejects anything that isn't exactly two numbers separated by a colon,
/// and anything where the hours are outside 0–23 or the minutes 0–59.
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

/// Minutes since midnight → "08:00". Pads to two digits.
String formatTime(int minutes) {
  final h = (minutes ~/ 60).toString().padLeft(2, '0');
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

/// 210 → "3h 30m", 120 → "2h", 30 → "30m".
String formatDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

/// Two courses clash if they're on the same day, and each starts before
/// the other ends. A course ending at 11:00 and one starting at 11:00
/// do NOT clash — this is the boundary rule from the assignment.
bool clashes(Course a, Course b) {
  if (identical(a, b)) return false;
  if (a.day != b.day) return false;
  return a.startMinutes < b.endMinutes && b.startMinutes < a.endMinutes;
}

/// Returns the names of every course in [all] that clash with [course].
/// Excludes [course] itself (the `clashes` function handles that).
List<String> clashNames(Course course, List<Course> all) {
  return all
      .where((other) => clashes(course, other))
      .map((c) => c.name)
      .toList();
}