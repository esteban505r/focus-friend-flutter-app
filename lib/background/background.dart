import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import '../main.dart';

const String updateNotificationsTask = "updateNotificationsTask";

@pragma('vm:entry-point')
void updateNotifications() {
  Workmanager().executeTask((task, inputData) async {
    // Inicializa la librería de TimeZone
    try{
      tz.initializeTimeZones();

      // Aquí debes llamar a la función `scheduleNotifications()` que creaste anteriormente
      await scheduleNotifications();
    }
    catch(e){
      print(e);
    }

    // Retorna true para indicar que la tarea se completó correctamente
    return Future.value(true);
  });
}
