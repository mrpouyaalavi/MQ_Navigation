import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syllabus_sync/features/home/data/repositories/dashboard_repository.dart';
import 'package:syllabus_sync/shared/models/academic_models.dart';

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardSnapshot>(
      DashboardController.new,
    );

class DashboardController extends AsyncNotifier<DashboardSnapshot> {
  @override
  Future<DashboardSnapshot> build() {
    return ref.read(dashboardRepositoryProvider).loadDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(
      await ref.read(dashboardRepositoryProvider).loadDashboard(),
    );
  }
}
