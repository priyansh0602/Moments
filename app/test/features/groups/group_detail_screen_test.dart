import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moments/features/groups/data/groups_repository.dart';
import 'package:moments/features/groups/domain/models/group_item.dart';
import 'package:moments/features/groups/domain/models/moment_group.dart';
import 'package:moments/features/groups/presentation/group_detail_screen.dart';
import 'package:moments/features/moments/domain/models/moment.dart';

class MockGroupsRepository extends Mock implements GroupsRepository {}

void main() {
  group('GroupDetailScreen Widget Tests', () {
    late MockGroupsRepository mockRepository;

    final testGroup = MomentGroup(
      id: 'g-1',
      userId: 'u-1',
      name: 'Gym Hype',
      description: 'Adrenaline pumping bass drops',
      createdAt: DateTime.now(),
      momentCount: 1,
    );

    final testMoment = Moment(
      id: 'm-1',
      userId: 'u-1',
      videoId: 'vid-123',
      title: 'Power Track',
      artist: 'Synth Master',
      thumbnailUrl: '',
      startSeconds: 15.0,
      endSeconds: 45.0,
      createdAt: DateTime.now(),
    );

    final testGroupItem = GroupItem(
      id: 'gi-1',
      groupId: 'g-1',
      momentId: 'm-1',
      position: 0,
      addedAt: DateTime.now(),
      moment: testMoment,
    );

    setUp(() {
      mockRepository = MockGroupsRepository();
      when(() => mockRepository.getMyGroups())
          .thenAnswer((_) async => [testGroup]);
    });

    Widget createWidgetUnderTest({required List<GroupItem> items}) {
      when(() => mockRepository.getGroupItems('g-1'))
          .thenAnswer((_) async => items);

      return ProviderScope(
        overrides: [
          groupsRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: MaterialApp(
          home: GroupDetailScreen(group: testGroup),
        ),
      );
    }

    testWidgets('1. Displays empty state when group has no items', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(items: []));
      await tester.pumpAndSettle();

      expect(find.text('No Moments in this group yet'), findsOneWidget);
      expect(find.text('Browse Your Moments'), findsOneWidget);
      expect(find.text('0 Moments'), findsOneWidget);
    });

    testWidgets('2. Displays list of moments when items exist', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(items: [testGroupItem]));
      await tester.pumpAndSettle();

      expect(find.text('Power Track'), findsOneWidget);
      expect(find.text('Synth Master'), findsOneWidget);
      expect(find.text('00:15–00:45'), findsOneWidget);
      expect(find.text('1 Moment'), findsOneWidget);
    });

    testWidgets('3. More options menu opens dialog for Edit Group', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(items: [testGroupItem]));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Group Options'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Group'), findsOneWidget);
      expect(find.text('Delete Group'), findsOneWidget);

      await tester.tap(find.text('Edit Group'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Gym Hype'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Adrenaline pumping bass drops'), findsOneWidget);
    });
  });
}
