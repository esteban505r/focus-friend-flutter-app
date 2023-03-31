DateTime parseTimeString(String timeString) {
  List<String> timeParts = timeString.split(':');
  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);

  DateTime now = DateTime.now();
  DateTime time = DateTime(now.year, now.month, now.day, hour, minute);

  return time;
}