import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/presentation/providers/filter_providers.dart';

void main() {
  late TaskFilterNotifier notifier;

  setUp(() {
    notifier = TaskFilterNotifier();
  });

  group('TaskFilterNotifier', () {
    test('initial state has all fields null', () {
      expect(notifier.state, const TaskFilter());
      expect(notifier.state.status, isNull);
      expect(notifier.state.priority, isNull);
      expect(notifier.state.categoryId, isNull);
      expect(notifier.state.searchQuery, isNull);
    });

    test('setStatus updates only status', () {
      notifier.setStatus(TaskStatus.completed);

      expect(notifier.state.status, TaskStatus.completed);
      expect(notifier.state.priority, isNull);
      expect(notifier.state.categoryId, isNull);
    });

    test('setPriority updates only priority', () {
      notifier.setPriority(Priority.high);

      expect(notifier.state.priority, Priority.high);
      expect(notifier.state.status, isNull);
    });

    test('setCategoryId updates only categoryId', () {
      notifier.setCategoryId('cat-1');

      expect(notifier.state.categoryId, 'cat-1');
      expect(notifier.state.status, isNull);
    });

    test('setSearchQuery updates only searchQuery', () {
      notifier.setSearchQuery('buy');

      expect(notifier.state.searchQuery, 'buy');
      expect(notifier.state.status, isNull);
    });

    test('multiple filters can be set independently', () {
      notifier.setStatus(TaskStatus.pending);
      notifier.setPriority(Priority.high);
      notifier.setCategoryId('cat-1');
      notifier.setSearchQuery('urgent');

      expect(notifier.state.status, TaskStatus.pending);
      expect(notifier.state.priority, Priority.high);
      expect(notifier.state.categoryId, 'cat-1');
      expect(notifier.state.searchQuery, 'urgent');
    });

    test('clearAll resets to initial state', () {
      notifier.setStatus(TaskStatus.completed);
      notifier.setPriority(Priority.low);
      notifier.setCategoryId('cat-1');
      notifier.setSearchQuery('test');

      notifier.clearAll();

      expect(notifier.state, const TaskFilter());
      expect(notifier.state.status, isNull);
      expect(notifier.state.priority, isNull);
      expect(notifier.state.categoryId, isNull);
      expect(notifier.state.searchQuery, isNull);
    });

    test('setting null clears individual filter', () {
      notifier.setStatus(TaskStatus.pending);
      notifier.setStatus(null);

      expect(notifier.state.status, isNull);
    });
  });
}
