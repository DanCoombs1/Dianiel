// test/features/event_editor_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dianiels_calendar/models/calendar_event.dart';
import 'package:dianiels_calendar/repositories/event_repository.dart';
import 'package:dianiels_calendar/providers/repository_providers.dart';
import 'package:dianiels_calendar/providers/auth_providers.dart';
import 'package:dianiels_calendar/repositories/auth_repository.dart';
import 'package:dianiels_calendar/features/event/event_editor_screen.dart';
import 'package:dianiels_calendar/models/enums.dart';

class _CapturingRepo implements EventRepository {
  CalendarEvent? added;
  @override Future<String> add(CalendarEvent e) async { added = e; return 'id1'; }
  @override Stream<List<CalendarEvent>> watchAll() async* { yield const []; }
  @override Future<void> update(CalendarEvent e) async {}
  @override Future<void> delete(String id) async {}
}

class _FailingRepo implements EventRepository {
  @override Future<String> add(CalendarEvent e) async => throw Exception('network error');
  @override Stream<List<CalendarEvent>> watchAll() async* { yield const []; }
  @override Future<void> update(CalendarEvent e) async => throw Exception('network error');
  @override Future<void> delete(String id) async {}
}

void main() {
  testWidgets('entering a title and saving adds an event', (tester) async {
    // Make the virtual screen tall enough so all form fields fit without scrolling.
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = _CapturingRepo();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        eventRepositoryProvider.overrideWithValue(repo),
        authStateProvider.overrideWith(
          (ref) => Stream.value(const AppAuthUser(uid: 'uid1')),
        ),
      ],
      child: MaterialApp(home: EventEditorScreen(initialDate: DateTime(2026, 7, 4))),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('title')), 'Picnic');
    await tester.tap(find.byKey(const Key('save')));
    await tester.pumpAndSettle();
    expect(repo.added?.title, 'Picnic');
  });

  testWidgets('save error shows snackbar and does not pop', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        eventRepositoryProvider.overrideWithValue(_FailingRepo()),
        authStateProvider.overrideWith(
          (ref) => Stream.value(const AppAuthUser(uid: 'uid1')),
        ),
      ],
      child: MaterialApp(home: EventEditorScreen(initialDate: DateTime(2026, 7, 4))),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('title')), 'Fail event');
    await tester.tap(find.byKey(const Key('save')));
    await tester.pumpAndSettle();
    expect(find.text('Could not save event. Please try again.'), findsOneWidget);
    // editor still on screen (no pop)
    expect(find.byKey(const Key('save')), findsOneWidget);
  });

  testWidgets('pre-populates time from existing event startTime', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final existing = CalendarEvent(
      id: 'e1',
      title: 'Morning run',
      date: DateTime(2026, 7, 4),
      startTime: '09:30',
      allDay: false,
      owner: EventOwner.together,
      createdBy: 'uid1',
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        eventRepositoryProvider.overrideWithValue(_CapturingRepo()),
        authStateProvider.overrideWith(
          (ref) => Stream.value(const AppAuthUser(uid: 'uid1')),
        ),
      ],
      child: MaterialApp(home: EventEditorScreen(existing: existing)),
    ));
    await tester.pumpAndSettle();
    // The time tile should show the pre-populated time (09:30 AM in MaterialLocalizations)
    expect(find.textContaining('9:30'), findsOneWidget);
  });
}
