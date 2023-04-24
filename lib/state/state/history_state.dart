import 'package:flutter/material.dart';

import '../../task_status.dart';

@immutable
class HistoryState {
  final int month;
  final int year;
  final String activityId;

  const HistoryState(
      {required this.month, required this.year, required this.activityId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryState &&
          runtimeType == other.runtimeType &&
          month == other.month &&
          year == other.year;

  @override
  int get hashCode => month.hashCode ^ year.hashCode;

  HistoryState copyWith({
    int? month,
    int? year,
    String? activityId,
  }) {
    return HistoryState(
        month: month ?? this.month,
        year: year ?? this.year,
        activityId: activityId ?? this.activityId);
  }
}
