import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime parseTimeString(String timeString) {
  List<String> timeParts = timeString.split(':');
  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);

  DateTime now = DateTime.now();
  DateTime time = DateTime(now.year, now.month, now.day, hour, minute);

  return time;
}

String parse24to12(String hour) {
  final parsedTime = DateFormat('HH:mm').parse(hour);
  return DateFormat('hh:mm a').format(parsedTime);
}


String getStatus(String? status) {
  switch(status){
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

Color getStatusColor(String? status) {
  switch(status){
    case "completed":
      return Colors.green;
    case "omitted":
      return Colors.amber;
    case "pending":
      return Colors.deepPurpleAccent;
    default:
      return Colors.green;
  }
}