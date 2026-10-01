import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moments/core/widgets/moment_range_slider.dart';
import 'package:moments/features/moments/presentation/moment_creator_screen.dart';
import 'package:moments/features/moments/presentation/providers/trim_selection_provider.dart';
import 'package:moments/features/player/data/fake_player_controller.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MomentCreatorScreen Lifecycle & Edge-Case Tests', () {
    late FakePlayerController fakeController;

    setUp(() {
      fakeController = FakePlayerController();
    });

    tearDown(() {
      fakeController.dispose();
    });

    testWidgets(
        '1) Leaving trim screen while loop preview is active stops preview cleanly',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await fakeController.loadVideo(
        'v_test_yellow',
        title: 'Yellow',
        artist: 'Coldplay',
        duration: const Duration(seconds: 240),
      );

      final container = ProviderContainer(
        overrides: [
          playerControllerProvider.overrideWithValue(fakeController),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MomentCreatorScreen(),
                      ),
                    );
                  },
                  child: const Text('Open Creator'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open MomentCreatorScreen
      await tester.tap(find.text('Open Creator'));
      await tester.pumpAndSettle();

      expect(find.byType(MomentCreatorScreen), findsOneWidget);

      // Activate loop preview
      final previewButton = find.text('Loop Preview Moment');
      expect(previewButton, findsOneWidget);
      await tester.tap(previewButton);
      await tester.pumpAndSettle();

      // Verify loop preview is actively playing on controller
      expect(fakeController.previewStartSeconds, isNotNull);
      expect(fakeController.previewEndSeconds, isNotNull);
      expect(fakeController.previewLoop, isTrue);
      expect(container.read(trimSelectionProvider).isPreviewing, isTrue);
      expect(find.text('Stop Loop Preview'), findsOneWidget);

      // Pop / leave the screen (simulating user tapping back button or navigating away)
      final backButton = find.byTooltip('Back to Player');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Screen is popped back to root
      expect(find.byType(MomentCreatorScreen), findsNothing);

      // Verify loop preview has been completely stopped and cleaned up
      expect(fakeController.previewStartSeconds, isNull);
      expect(fakeController.previewEndSeconds, isNull);
      expect(container.read(trimSelectionProvider).isPreviewing, isFalse);

      container.dispose();
    });

    testWidgets(
        '2) Opening trim screen before duration is known handles loading gracefully without broken slider',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Song is loading: videoId is present, but duration is zero / unknown
      await fakeController.loadVideo(
        'v_buffering_track',
        title: 'Buffering Track',
        artist: 'Unknown Artist',
        duration: Duration.zero, // unknown / zero duration
      );

      final container = ProviderContainer(
        overrides: [
          playerControllerProvider.overrideWithValue(fakeController),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MomentCreatorScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify the screen does NOT crash with RangeSlider min/max assertion error
      // Instead, it shows the graceful loading placeholder
      expect(find.text('Loading track timeline...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MomentRangeSlider), findsNothing);

      // Verify Save Moment button is disabled while duration is unknown
      final saveButtonFinder = find.byType(FilledButton);
      expect(saveButtonFinder, findsOneWidget);
      final FilledButton saveButton = tester.widget(saveButtonFinder);
      expect(saveButton.onPressed, isNull);

      // Now simulate track finishing buffering and reporting its real duration
      await fakeController.loadVideo(
        'v_buffering_track',
        title: 'Buffering Track',
        artist: 'Unknown Artist',
        duration: const Duration(seconds: 180),
      );
      await tester.pumpAndSettle();

      // Loading state disappears, range slider is gracefully rendered
      expect(find.text('Loading track timeline...'), findsNothing);
      expect(find.byType(MomentRangeSlider), findsOneWidget);

      // Save button is now enabled
      final FilledButton updatedSaveButton = tester.widget(saveButtonFinder);
      expect(updatedSaveButton.onPressed, isNotNull);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
    });
  });
}
