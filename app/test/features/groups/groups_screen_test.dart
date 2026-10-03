import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moments/features/groups/data/groups_repository.dart';
import 'package:moments/features/groups/domain/models/moment_group.dart';
import 'package:moments/features/groups/presentation/groups_screen.dart';

class MockGroupsRepository extends Mock implements GroupsRepository {}

void main() {
  group('GroupsScreen Widget Tests', () {
    late MockGroupsRepository mockRepository;

    final testGroup1 = MomentGroup(
      id: 'g-1',
      userId: 'u-1',
      name: 'Late Night Chill',
      description: 'Dreamy synthwave',
      createdAt: DateTime.now(),
      momentCount: 4,
    );

    setUp(() {
      mockRepository = MockGroupsRepository();
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          groupsRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: GroupsScreen(),
        ),
      );
    }

    testWidgets('1. Displays empty state when user has no groups', (tester) async {
      when(() => mockRepository.getMyGroups()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('No Groups Yet'), findsOneWidget);
      expect(find.text('Create First Group'), findsOneWidget);
    });

    testWidgets('2. Displays list of groups when populated', (tester) async {
      when(() => mockRepository.getMyGroups())
          .thenAnswer((_) async => [testGroup1]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Late Night Chill'), findsOneWidget);
      expect(find.text('4 Moments'), findsOneWidget);
      expect(find.text('Dreamy synthwave'), findsOneWidget);
    });

    testWidgets('3. Tapping create action opens create group dialog', (tester) async {
      when(() => mockRepository.getMyGroups()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create First Group'));
      await tester.pumpAndSettle();

      expect(find.text('Create Group'), findsOneWidget);
      expect(find.text('Group Name'), findsOneWidget);
      expect(find.text('Description (Optional)'), findsOneWidget);
    });
  });
}
