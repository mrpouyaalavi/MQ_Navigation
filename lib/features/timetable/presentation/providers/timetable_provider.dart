import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_navigation/features/timetable/data/repositories/timetable_repository.dart';
import 'package:mq_navigation/features/timetable/domain/entities/timetable_class.dart';

final timetableClassesProvider = FutureProvider<List<TimetableClass>>((ref) {
  return ref.watch(timetableRepositoryProvider).loadClasses();
});

final nextTimetableClassProvider = FutureProvider<TimetableClass?>((ref) async {
  final classes = await ref.watch(timetableClassesProvider.future);
  final now = DateTime.now();
  final today = classes.where((item) {
    final local = item.startTime;
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  });
  final upcoming = today.where((item) => item.startTime.isAfter(now)).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  return upcoming.isEmpty ? null : upcoming.first;
});
