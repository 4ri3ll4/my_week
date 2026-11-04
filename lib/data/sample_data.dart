import '../models/course.dart';

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