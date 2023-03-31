import 'package:focus_friend/task_status.dart';

class TaskState {
  TaskStatus status;
  int hoursRemaining;

  int minutesRemaining;

  TaskState({this.status = TaskStatus
      .PENDING, this.hoursRemaining = 0, this.minutesRemaining = 0});

  TaskState copyWith(TaskStatus? status, int? hoursRemaining,
      int? minutesRemaining) {
    return TaskState(status: status ?? this.status,
        hoursRemaining: hoursRemaining ?? this.hoursRemaining,
        minutesRemaining: minutesRemaining ?? this.minutesRemaining);
  }
}