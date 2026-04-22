import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mq_navigation/features/map/domain/entities/map_renderer_type.dart';
import 'package:mq_navigation/features/map/domain/entities/route_leg.dart';
import 'package:mq_navigation/features/settings/data/repositories/settings_repository.dart';
import 'package:mq_navigation/features/settings/presentation/controllers/settings_controller.dart';
import 'package:mq_navigation/shared/models/user_preferences.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository repository;

  setUp(() {
    repository = MockSettingsRepository();
    // Default mock behavior
    when(() => repository.loadPreferences()).thenAnswer(
      (_) async => const UserPreferences(),
    );
    registerFallbackValue(const UserPreferences());
    when(() => repository.savePreferences(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments[0] as UserPreferences,
    );
    when(() => repository.wipeAllLocalData()).thenAnswer((_) async {});
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('SettingsController wiring tests', () {
    test('updateDefaultRenderer updates state and repository', () async {
      final container = createContainer();
      final controller = container.read(settingsControllerProvider.notifier);

      await controller.updateDefaultRenderer(MapRendererType.google);

      final state = container.read(settingsControllerProvider).value;
      expect(state?.defaultRenderer, MapRendererType.google);
      verify(() => repository.savePreferences(any(
        that: isA<UserPreferences>().having(
          (p) => p.defaultRenderer,
          'defaultRenderer',
          MapRendererType.google,
        ),
      ))).called(1);
    });

    test('updateDefaultTravelMode updates state and repository', () async {
      final container = createContainer();
      final controller = container.read(settingsControllerProvider.notifier);

      await controller.updateDefaultTravelMode(TravelMode.drive);

      final state = container.read(settingsControllerProvider).value;
      expect(state?.defaultTravelMode, TravelMode.drive);
      verify(() => repository.savePreferences(any(
        that: isA<UserPreferences>().having(
          (p) => p.defaultTravelMode,
          'defaultTravelMode',
          TravelMode.drive,
        ),
      ))).called(1);
    });

    test('updateLowDataMode updates state and repository', () async {
      final container = createContainer();
      final controller = container.read(settingsControllerProvider.notifier);

      await controller.updateLowDataMode(true);

      final state = container.read(settingsControllerProvider).value;
      expect(state?.lowDataMode, isTrue);
      verify(() => repository.savePreferences(any(
        that: isA<UserPreferences>().having(
          (p) => p.lowDataMode,
          'lowDataMode',
          isTrue,
        ),
      ))).called(1);
    });

    test('updateReducedMotion updates state and repository', () async {
      final container = createContainer();
      final controller = container.read(settingsControllerProvider.notifier);

      await controller.updateReducedMotion(true);

      final state = container.read(settingsControllerProvider).value;
      expect(state?.reducedMotion, isTrue);
      verify(() => repository.savePreferences(any(
        that: isA<UserPreferences>().having(
          (p) => p.reducedMotion,
          'reducedMotion',
          isTrue,
        ),
      ))).called(1);
    });

    test('wipeAllLocalData calls repository and resets state', () async {
      final container = createContainer();
      final controller = container.read(settingsControllerProvider.notifier);

      // Change a value first
      await controller.updateLowDataMode(true);
      expect(container.read(settingsControllerProvider).value?.lowDataMode, isTrue);

      // Setup repository to return defaults on next load
      when(() => repository.loadPreferences()).thenAnswer(
        (_) async => const UserPreferences(),
      );

      await controller.wipeAllLocalData();

      verify(() => repository.wipeAllLocalData()).called(1);
      final state = container.read(settingsControllerProvider).value;
      expect(state?.lowDataMode, isFalse); // Reset to default
    });
  });
}
