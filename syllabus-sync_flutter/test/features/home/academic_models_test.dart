import 'package:flutter_test/flutter_test.dart';
import 'package:syllabus_sync/shared/models/academic_models.dart';

void main() {
  group('StressSnapshot', () {
    test('elevates score for overdue and urgent work', () {
      final now = DateTime.now();
      final snapshot = StressSnapshot.fromData(
        deadlines: [
          DeadlineItem(
            unitCode: 'COMP1010',
            title: 'Assignment',
            dueDate: now.subtract(const Duration(hours: 2)),
          ),
          DeadlineItem(
            unitCode: 'COMP1020',
            title: 'Quiz',
            dueDate: now.add(const Duration(days: 1)),
          ),
        ],
        todos: [
          TodoItem(
            title: 'Revise lecture',
            priority: 'high',
            dueDate: now.subtract(const Duration(hours: 3)),
          ),
        ],
        upcomingEvents: [
          AcademicEvent(
            title: 'Study group',
            startAt: now.add(const Duration(hours: 2)),
          ),
        ],
      );

      expect(snapshot.score, greaterThan(40));
      expect(snapshot.label, anyOf('Busy', 'Critical'));
    });
  });

  group('GamificationProfile', () {
    test('derives level and progress from xp', () {
      const profile = GamificationProfile(xp: 620, streakDays: 7);

      expect(profile.level, 3);
      expect(profile.xpIntoLevel, 120);
      expect(profile.progressToNextLevel, closeTo(0.48, 0.001));
    });
  });
}
