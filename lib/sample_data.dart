import 'course.dart';

/// Sample timetable for the first run.
/// Covers: a boundary case (Math ends 10:00, Physics starts 10:00 — no clash),
/// a real clash (Chemistry 09:00–11:00 vs Biology 10:00–12:00 on Tuesday),
/// and an empty day (Wednesday) for the "No classes on Wednesday" message.
List<Course> sampleCourses() {
  return [
    Course(name: 'Math',      day: 0, startMinutes: 8 * 60,  endMinutes: 10 * 60),
    Course(name: 'Physics',   day: 0, startMinutes: 10 * 60, endMinutes: 11 * 60 + 30),
    Course(name: 'Chemistry', day: 1, startMinutes: 9 * 60,  endMinutes: 11 * 60),
    Course(name: 'Biology',   day: 1, startMinutes: 10 * 60, endMinutes: 12 * 60),
    Course(name: 'History',   day: 3, startMinutes: 14 * 60, endMinutes: 15 * 60 + 30),
    Course(name: 'English',   day: 4, startMinutes: 8 * 60,  endMinutes: 9 * 60),
  ];
}