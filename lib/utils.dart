import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:focus_friend/model/calendar_history_cell_style.dart';
import 'package:focus_friend/task_status.dart';
import 'package:intl/intl.dart';

import 'model/dto/history_item_model.dart';

DateTime parseTimeString(String timeString) {
  List<String> timeParts = timeString.split(':');
  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);

  DateTime now = DateTime.now();
  DateTime time = DateTime(now.year, now.month, now.day, hour, minute);

  return time;
}

String formatTimeOfDay(TimeOfDay timeOfDay) {
  final hour = timeOfDay.hour.toString().padLeft(2, '0');
  final minute = timeOfDay.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String parse24to12(String hour) {
  final parsedTime = DateFormat('HH:mm').parse(hour);
  return DateFormat('hh:mm a').format(parsedTime);
}

String formatYYYYMMdd(DateTime time) {
  return "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}";
}

int getSecondsByTimeString(String time) {
  try {
    var date = parseTimeString(time);
    Duration duration = date.difference(DateTime.now());
    if (!duration.isNegative) {
      return duration.inSeconds;
    }
    return 0;
  } catch (e) {
    return 0;
  }
}

TimeOfDay parseTimeOfDay(String time) {
  int hour = int.parse(time.split(':')[0]);
  int minute = int.parse(time.split(':')[1]);
  return TimeOfDay(hour: hour, minute: minute);
}

extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (hour < other.hour) return -1;
    if (hour > other.hour) return 1;
    if (minute < other.minute) return -1;
    if (minute > other.minute) return 1;
    return 0;
  }
}

String getTimeRemaining(int secondsRemaining) {
  final duration = Duration(seconds: secondsRemaining);
  return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
}

String getStatus(String? status) {
  switch (status) {
    case "completed":
      return "Completado";
    case "omitted":
      return "Omitido";
    case "pending":
      return "Pendiente";
    default:
      return '';
  }
}

CalendarHistoryCellStyle? getCalendarCellStyleByHistoryItemList(
    {required DateTime date,
    required List<HistoryItemModel> history,
    required String status,
    required Color backgroundColor}) {
  final currentList = history
      .where((element) =>
          date.month == element.changedDateTime!.month &&
          date.day == element.changedDateTime!.day &&
          element.newStatus == status)
      .toList();

  if (currentList.isNotEmpty) {
    final dayBeforeList = history.where((element) {
      final dayBeforeDate = date.subtract(const Duration(days: 1));

      return (dayBeforeDate.month == element.changedDateTime!.month &&
          dayBeforeDate.day == element.changedDateTime!.day &&
          element.newStatus == status);
    });

    final dayAfterList = history.where((element) {
      final dayAfterDate = date.add(const Duration(days: 1));

      return (dayAfterDate.month == element.changedDateTime!.month &&
          dayAfterDate.day == element.changedDateTime!.day &&
          element.newStatus == status);
    });

    if (dayBeforeList.isNotEmpty && dayAfterList.isNotEmpty ||
        dayBeforeList.isEmpty && dayAfterList.isEmpty) {
      return CalendarHistoryCellStyle(
          backgroundColor: backgroundColor,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(0),
              bottomRight: Radius.circular(0),
              bottomLeft: Radius.circular(0),
              topLeft: Radius.circular(0)));
    }

    if (dayBeforeList.isNotEmpty) {
      return CalendarHistoryCellStyle(
          backgroundColor: backgroundColor,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
              bottomLeft: Radius.circular(0),
              topLeft: Radius.circular(0)));
    }

    if (dayAfterList.isNotEmpty) {
      return CalendarHistoryCellStyle(
          backgroundColor: backgroundColor,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(0),
              bottomRight: Radius.circular(0),
              bottomLeft: Radius.circular(30),
              topLeft: Radius.circular(30)));
    }
  }
  return null;
}

Color getStatusColor(String? status) {
  switch (status) {
    case "completed":
      return Colors.green;
    case "omitted":
      return Color(0xFFF57C00);
    case "pending":
      return Color(0xFFEDB536);
    default:
      return Colors.green;
  }
}
