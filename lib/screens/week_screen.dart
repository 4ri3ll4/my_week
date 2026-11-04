import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../state/course_state.dart';
import '../widgets/weather_chip.dart';
import 'course_screen.dart';

class WeekScreen extends StatelessWidget {
  const WeekScreen({super.key});

    static const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    static const dayFullNames = [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            ];

    @override
    Widget build(BuildContext context) {
        final state = context.watch<CourseState>();
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
        Text('This week',
                style: Theme.of(context).textTheme.titleMedium),
        Text(
                formatDuration(state.weekMinutes),
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
                selected: state.selectedDay == i,
                onSelected: (_) =>
                context.read<CourseState>().setDay(i),
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
                dayFullNames[state.selectedDay],
                style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                        formatDuration(state.dayMinutes),
                        style: const TextStyle(
                color: Colors.teal, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        // Search box — required for the filter feature (step 18).
        Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                onChanged: (text) =>
                context.read<CourseState>().setQuery(text),
                decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search courses',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 8),
        Expanded(child: _body(state)),
        ],
      ),
        floatingActionButton: FloatingActionButton(
                onPressed: () => _openForm(context, null),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
      ),
    );
    }

    Widget _body(CourseState state) {
        if (state.error != null) {
            return Center(
                    child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(state.error!, textAlign: TextAlign.center),
        ),
      );
        }
        if (state.loading) {
            return const Center(child: CircularProgressIndicator());
        }
        if (state.courses.isEmpty) {
            return const Center(
                    child: Text('No courses yet. Tap + to add one.',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
        }
        if (state.dayCourses.isEmpty) {
            return Center(
                    child: Text(
                    'No classes on ${dayFullNames[state.selectedDay]}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
        }
        final visible = state.visibleCourses;
        if (visible.isEmpty) {
            return const Center(
                    child: Text('Nothing matches your search.',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
        }
        return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: visible.length,
                itemBuilder: (context, index) {
            final course = visible[index];
            final clashing = clashNames(course, state.courses);
            return CourseTile(
                    course: course,
                    clashesWith: clashing,
                    onTap: () => _openForm(context, course),
        );
        },
    );
    }

    void _openForm(BuildContext context, Course? course) {
        final state = context.read<CourseState>();
        Navigator.push(
                context,
                MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider<CourseState>.value(
                value: state,
                child: CourseScreen(course: course),
        ),
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