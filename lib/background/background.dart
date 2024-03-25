import 'package:focus_friend/utils/notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';


const String updateNotificationsTask = "updateNotificationsTask";

@pragma('vm:entry-point')
void updateNotifications() {
  Workmanager().executeTask((task, inputData) async {
    try{
      tz.initializeTimeZones();
      await scheduleActivitiesNotifications();
    }
    catch(e){
      print(e);
    }
    return Future.value(true);
  });
}
