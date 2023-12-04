import 'package:flutter/material.dart';

import '../../task_status.dart';

@immutable
class TasksState {
  final DateTime dateTime;

  const TasksState({
    required this.dateTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TasksState &&
              runtimeType == other.runtimeType &&
              dateTime == other.dateTime;

  @override
  int get hashCode => dateTime.hashCode;

  TasksState copyWith({
    DateTime? dateTime,
  }) {
    return TasksState(
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
