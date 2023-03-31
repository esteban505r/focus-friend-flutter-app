import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';

import '../main.dart';

const String updateNotificationsTask = "updateNotificationsTask";

@pragma('vm:entry-point')
void updateNotifications() {
  Workmanager().executeTask((task, inputData) async {
    try{
      tz.initializeTimeZones();
      await scheduleNotifications();
    }
    catch(e){
      print(e);
    }
    return Future.value(true);
  });
}
