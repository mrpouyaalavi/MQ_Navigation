import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:mq_navigation/core/logging/app_logger.dart';
import 'package:mq_navigation/features/timetable/data/repositories/timetable_repository.dart';
import 'package:mq_navigation/features/timetable/domain/entities/timetable_class.dart';

final timetableImportServiceProvider = Provider<TimetableImportService>((ref) {
  return TimetableImportService(
    repository: ref.watch(timetableRepositoryProvider),
  );
});

class TimetableImportService {
  const TimetableImportService({required TimetableRepository repository})
    : _repository = repository;

  final TimetableRepository _repository;

  Future<int> importFromPicker() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['ics'],
    );
    final path = result?.files.single.path;
    if (path == null) {
      return 0;
    }

    final raw = await File(path).readAsString();
    final classes = _parseClasses(raw);
    await _repository.saveClasses(classes);
    return classes.length;
  }

  List<TimetableClass> _parseClasses(String rawIcs) {
    try {
      final calendar = ICalendar.fromString(rawIcs);
      final records = calendar.data;

      return records
          .where((record) => record['type'] == 'VEVENT')
          .map((record) {
            final data = (record['data'] as Map<dynamic, dynamic>? ?? {});
            final summary = (data['summary'] ?? '').toString();
            final location = (data['location'] ?? '').toString();
            final dtStart = data['dtstart'];
            final startIso = _toIso(dtStart);
            return TimetableClass(
              location: location,
              name: summary,
              startIso: startIso,
            );
          })
          .where((entry) => entry.name.trim().isNotEmpty)
          .toList();
    } catch (error, stackTrace) {
      AppLogger.warning('ICS parse failed', error, stackTrace);
      return const [];
    }
  }

  String _toIso(dynamic value) {
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    if (value is String) {
      return DateTime.tryParse(value)?.toUtc().toIso8601String() ??
          DateTime.now().toUtc().toIso8601String();
    }
    return DateTime.now().toUtc().toIso8601String();
  }
}
