import 'package:flutter/material.dart';

import '../task_status.dart';

@immutable
class TaskState {
  final String id;
  final TaskStatus status;
  final int secondsRemaining;

  const TaskState(this.id, {
    this.status = TaskStatus.PENDING,
    this.secondsRemaining = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TaskState &&
              runtimeType == other.runtimeType &&
              status == other.status &&
              secondsRemaining == other.secondsRemaining;

  @override
  int get hashCode => status.hashCode ^ secondsRemaining.hashCode;

  TaskState copyWith({
    TaskStatus? status,
    int? secondsRemaining,
  }) {
    return TaskState(
      id,
      status: status ?? this.status,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    );
  }
}
