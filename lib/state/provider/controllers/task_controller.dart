import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/task_state.dart';

class TaskController extends StateNotifier<TaskState> {
  final TaskState taskState;

  TaskController(this.taskState) : super(taskState);

  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        _timer?.cancel();
      }
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

  void setSecondsRemaining(int? secondsRemaining) {
    state = state.copyWith(secondsRemaining: secondsRemaining);
  }
}

final taskController = StateNotifierProvider.autoDispose
    .family<TaskController, TaskState, String>((ref, id) {
  return TaskController(TaskState(id));
});
