import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'course.dart';
import 'course_screen.dart';
import 'sample_data.dart';
import 'weather_chip.dart';

void main() {
  runApp(const ClassFlowApp());
}

class ClassFlowApp extends StatelessWidget {
  const ClassFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClassFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const WeekScreen(),
    );
  }
}

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  List<Course> courses = [];
  bool loaded = false;
  int selectedDay = 0;

  static const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
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
    start();
  }

  Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('courses');
    List<Course> loadedCourses;
    if (saved != null) {
      final list = jsonDecode(saved) as List;
      loadedCourses = list
          .map((x) => Course.fromJson(x as Map<String, dynamic>))
          .toList();
    } else {
      loadedCourses = sampleCourses();
    }
    setState(() {
      courses = loadedCourses;
      loaded = true;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = courses.map((c) => c.toJson()).toList();
    await prefs.setString('courses', jsonEncode(list));
  }

  List<Course> get dayCourses {
    final list = courses.where((c) => c.day == selectedDay).toList();
    list.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return list;
  }

  int get dayMinutes =>
      dayCourses.fold(0, (sum, c) => sum + c.durationMinutes);

  int get weekMinutes =>
      courses.fold(0, (sum, c) => sum + c.durationMinutes);

  Future<void> _openAddCourse() async {
    final result = await Navigator.push<CourseScreenResult>(
      context,
      MaterialPageRoute(builder: (_) => const CourseScreen()),
    );
    if (result == null) return; // user cancelled
    setState(() {
      courses.add(result.course!);
      selectedDay = result.course!.day; // jump to the day they added
    });
    await _save();
  }

  Future<void> _openEditCourse(Course course) async {
    final result = await Navigator.push<CourseScreenResult>(
      context,
      MaterialPageRoute(builder: (_) => CourseScreen(course: course)),
    );
    if (result == null) return; // user cancelled
    if (result.deleted) {
      setState(() => courses.remove(course));
      await _save();
      return;
    }
    setState(() {
      final i = courses.indexOf(course);
      if (i != -1) courses[i] = result.course!;
    });
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClassFlow'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: WeatherChip()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This week',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  formatDuration(weekMinutes),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  for (int i = 0; i < dayNames.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(dayNames[i]),
                        selected: selectedDay == i,
                        onSelected: (_) => setState(() => selectedDay = i),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Text(
                  dayFullNames[selectedDay],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  formatDuration(dayMinutes),
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: !loaded
                ? const Center(child: CircularProgressIndicator())
                : dayCourses.isEmpty
                    ? Center(
              child: Text(
                'No classes on ${dayFullNames[selectedDay]}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dayCourses.length,
              itemBuilder: (context, index) {
                final course = dayCourses[index];
                final clashing = clashNames(course, courses);
                return CourseTile(
                  course: course,
                  clashesWith: clashing,
                  onTap: () => _openEditCourse(course),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: loaded
          ? FloatingActionButton(
        onPressed: _openAddCourse,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}

class CourseTile extends StatelessWidget {
  const CourseTile({
    super.key,
    required this.course,
    required this.clashesWith,
    required this.onTap,
  });

  final Course course;
  final List<String> clashesWith;
  final VoidCallback onTap;

  bool get hasClash => clashesWith.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: hasClash ? Colors.red.shade50 : null,
      shape: hasClash
          ? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.red, width: 1.5),
      )
          : null,
      child: ListTile(
        title: Text(
          course.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: hasClash ? Colors.red.shade900 : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${formatTime(course.startMinutes)} – ${formatTime(course.endMinutes)}'
                  '  ·  ${formatDuration(course.durationMinutes)}',
            ),
            if (hasClash)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Clashes with ${clashesWith.join(', ')}',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        onTap: onTap,
        trailing: const Icon(
          Icons.edit_outlined,
          size: 18,
          color: Colors.grey,
        ),
      ),
    );
  }
}