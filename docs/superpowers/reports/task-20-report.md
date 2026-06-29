# Task 20 Report — TodoItem model + Firestore repository

## Files Created / Modified

| Action | Path |
|--------|------|
| Created | `lib/models/todo_item.dart` |
| Created | `lib/repositories/todo_repository.dart` |
| Modified | `lib/providers/repository_providers.dart` (added import + `todoRepositoryProvider`) |
| Created | `test/repositories/todo_repository_test.dart` |

## TDD Process

1. Wrote `test/repositories/todo_repository_test.dart` first (red — files missing).
2. Ran `flutter test test/repositories/todo_repository_test.dart` → confirmed compile failure.
3. Implemented `TodoItem` model, `TodoRepository` abstract class + `FirestoreTodoRepository`, and appended `todoRepositoryProvider` to `repository_providers.dart`.
4. Re-ran targeted test → 4/4 green.

## Test Output

### Targeted suite (`flutter test test/repositories/todo_repository_test.dart`)
```
00:01 +4: All tests passed!
```

4 tests:
- add then watchAll returns the todo with correct title and done=false — PASS
- update toggles done to true (watchAll reflects it, id preserved) — PASS
- setting scheduledDate via update round-trips a non-null DateTime — PASS
- delete removes the todo — PASS

### Full suite (`flutter test`)
```
00:03 +37: All tests passed!
```
37 tests total (was 33 before this task; +4 new).

### Analyze (`flutter analyze`)
```
No issues found! (ran in 1.6s)
```

## Implementation Notes

- `TodoItem` is `const`-constructible (immutable, no mutable fields).
- `toFirestore()` writes `scheduledDate` as `Timestamp?` (null when null), plus `createdAt: FieldValue.serverTimestamp()`.
- `fromFirestore` reads `scheduledDate` back from `Timestamp?` → `DateTime?`.
- `copyWith` uses `scheduledDate ?? this.scheduledDate` (clearing not required per spec).
- `FirestoreTodoRepository` mirrors `FirestoreEventRepository` exactly: `watchAll` maps snapshots, `add` returns `ref.id`, `update` by `t.id`, `delete` by `id`; collection is `todos`.
- `todoRepositoryProvider` appended to `repository_providers.dart` without disturbing existing providers.

## Concerns

None. The `toFirestore()` call on `update` re-writes `createdAt: FieldValue.serverTimestamp()` on every update (same pattern as the existing event repo writing `updatedAt`). This is benign in Firestore but worth noting — Task 21 may want to split `createdAt` out of `toFirestore()` if it matters.
