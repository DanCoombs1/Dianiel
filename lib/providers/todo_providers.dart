import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import 'repository_providers.dart';

final todosProvider = StreamProvider<List<TodoItem>>(
  (ref) => ref.watch(todoRepositoryProvider).watchAll(),
);
