import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/state/state/tasks_state.dart';

import '../../state/task_state.dart';

class TasksController extends StateNotifier<TasksState> {
  final TasksState taskState;

  TasksController(this.taskState) : super(taskState);

  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(dateTime: DateTime.now());
    });
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    _timer?.cancel();
    start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final taskController = StateNotifierProvider.autoDispose<TasksController, TasksState>((ref) {
  return TasksController(TasksState(dateTime:DateTime.now()));
});
