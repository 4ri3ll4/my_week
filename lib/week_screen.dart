import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'course.dart';
import 'course_screen.dart';
import 'weather_chip.dart';

CollectionReference<Map<String, dynamic>> myCourses() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('courses');
}

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  int selectedDay = 0;

  static const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  static const dayFullNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  Future<void> _openAddCourse() async {
    final result = await Navigator.push<CourseScreenResult>(
      context,
      MaterialPageRoute(builder: (_) => const CourseScreen()),
    );
    if (result == null || result.course == null) return;
    setState(() => selectedDay = result.course!.day);
    await myCourses().add(result.course!.toMap());
  }

  Future<void> _openEditCourse(Course course) async {
    final result = await Navigator.push<CourseScreenResult>(
      context,
      MaterialPageRoute(builder: (_) => CourseScreen(course: course)),
    );
    if (result == null) return;
    if (result.deleted) {
      await myCourses().doc(course.id).delete();
      return;
    }
    await myCourses().doc(course.id).update(result.course!.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClassFlow'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: myCourses().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load your courses.\n${snapshot.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }
          final hasData = snapshot.hasData;
          final courses = hasData
              ? snapshot.data!.docs.map(Course.fromDoc).toList()
              : <Course>[];
          final dayCourses = courses
              .where((c) => c.day == selectedDay)
              .toList()
            ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
          final dayMinutes =
          dayCourses.fold(0, (s, c) => s + c.durationMinutes);
          final weekMinutes =
          courses.fold(0, (s, c) => s + c.durationMinutes);

          return Column(
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
                    Text('This week',
                        style: Theme.of(context).textTheme.titleMedium),
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
                            onSelected: (_) =>
                                setState(() => selectedDay = i),
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
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      formatDuration(dayMinutes),
                      style: const TextStyle(
                          color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: !hasData
                    ? const Center(child: CircularProgressIndicator())
                    : dayCourses.isEmpty
                    ? Center(
                  child: Text(
                    'No classes on ${dayFullNames[selectedDay]}',
                    style: const TextStyle(
                        fontSize: 16, color: Colors.grey),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddCourse,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
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
        trailing: const Icon(Icons.edit_outlined,
            size: 18, color: Colors.grey),
      ),
    );
  }
}