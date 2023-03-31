import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/pages/base_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:focus_friend/utils.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'background/background.dart';
import 'firebase_options.dart';
import 'model/activity_model.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestPermission();

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  Workmanager().initialize(updateNotifications,isInDebugMode: true );
  Workmanager().registerPeriodicTask(
    "1",
    updateNotificationsTask,
    frequency: Duration(minutes: 15),
  );

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

const channelId = 'channelId';
const channelName = 'channelName';
const channelDescription = 'channelDescription';

void initializeNotification() async {
  var android = const AndroidNotificationDetails(channelId, channelName,
      importance: Importance.high, priority: Priority.high);

  var platform = NotificationDetails(android: android);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
      const AndroidNotificationChannel(channelId, channelName));
}


Future<void> scheduleNotifications() async {
  // Configura la instancia de FlutterLocalNotificationsPlugin
  FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initSettings = InitializationSettings(android: androidInitSettings);
  await localNotifications.initialize(initSettings);

  // Obtiene las horas de Firebase Realtime Database y actualiza las notificaciones en tiempo real
  final databaseReference = FirebaseDatabase.instance.ref().child('activities');
  DatabaseEvent event = await databaseReference.once();

  Map<dynamic, dynamic> values =
  event.snapshot.value as Map<dynamic, dynamic>;
  List<ActivityModel> activities = [];
  values.forEach((key, value) {
    activities
        .add(ActivityModel.fromJson(Map<String, dynamic>.from(value)));
  });
  activities.sort((a, b) {
    DateTime dateA = parseTimeString(a.time!);
    DateTime dateB = parseTimeString(b.time!);
    return dateA.compareTo(dateB);
  });

  // Cancela todas las notificaciones existentes
  localNotifications.cancelAll();

  // Programa las notificaciones basadas en las horas obtenidas
  for(ActivityModel activity in activities){
    DateTime date = parseTimeString(activity.time!);

    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
      'channel_id', 'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    // Programa la notificación
    await localNotifications.zonedSchedule(
      0,
      'Título de la notificación',
      'Contenido de la notificación',
      tz.TZDateTime.now(tz.local).add(
        Duration(
          days: (date.hour.compareTo(DateTime.now().hour) > 0) ? 0 : 1,
          hours: date.hour - DateTime.now().hour,
          minutes: date.minute - DateTime.now().hour,
        ),
      ),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Color(0xff8FBFE0), secondary: Color(0xff7F9C8D))),
      home: const BasePage(),
    );
  }
}
