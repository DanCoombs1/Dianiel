# Task 21 Report — Todo providers + TodoListScreen + "add to calendar"

## Files Created

- `lib/providers/todo_providers.dart` — `todosProvider = StreamProvider<List<TodoItem>>` watching `todoRepositoryProvider.watchAll()`
- `lib/features/todo/todo_list_screen.dart` — `TodoListScreen` (ConsumerStatefulWidget): AppBar "To-dos"; input field (Key `todo-input`) + add button (Key `todo-add`); CheckboxListTile rows with `done` toggle; "Scheduled · d MMM" subtitle when `scheduledDate != null`; calendar icon opens `showDatePicker` → calls `eventRepository.add(CalendarEvent(..., allDay:true, owner:together))` AND `todoRepository.update(todo.copyWith(scheduledDate: picked))`; delete icon per row; empty state "No to-dos yet 🌸".
- `test/features/todo_list_test.dart` — TDD widget tests with `FakeTodoRepository` (StreamController with `onListen` seeding) and `FakeEventRepository`; overrides `todoRepositoryProvider`, `eventRepositoryProvider`, and `authStateProvider`.

## Test Output

### Target tests (`flutter test test/features/todo_list_test.dart`)
```
+2: All tests passed!
```

### Full suite (`flutter test`)
```
+39: All tests passed!
```

### Analyze (`flutter analyze`)
```
No issues found! (ran in 1.8s)
```

## Implementation Notes / Concerns

1. **uid timing in widget tests**: `authStateProvider` is a `StreamProvider`; calling `ref.read(...).value` returns `null` during loading. The screen uses `ref.read(authStateProvider).value?.uid ?? 'unknown'`, which correctly falls back. In tests, after two `pump()` calls the `Stream.value(AppAuthUser(uid:'u1'))` resolves and subsequent `_add()` calls read `u1`. Test 1 (add) does not assert the specific uid value to avoid a brittle async race; the functional invariant (title and add being called) is verified. The production path correctly reads from the auth stream.

2. **StreamController in fake**: used a non-broadcast `StreamController` with `onListen` callback to emit the initial seed, per the spec's warning against bare `async*` single-yield streams that may lose events before subscription.

3. **`showDatePicker` promotion test skipped**: as the spec allows, the widget test for the date-picker calendar promotion is not included (driving `showDatePicker` in Flutter widget tests requires additional scaffold setup). The promotion code is fully implemented in `_scheduleOnCalendar`.

4. **No git operations performed** as required.
