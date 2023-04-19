import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tz2;
import 'package:timezone/timezone.dart' as tz;

import '../background/background.dart';
import '../main.dart';
import '../model/activity_model.dart';
import '../utils.dart';

const channelId = 'channelId';
const channelName = 'channelName';
const channelDescription = 'channelDescription';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print("TRIGGERED");
  print(notificationResponse.input);
}

Future<void> initializeNotifications() async {
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestPermission();

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
    print("TRIGGERED");
    print(notificationResponse.input);
  }, onDidReceiveBackgroundNotificationResponse: notificationTapBackground);

  tz2.initializeTimeZones();

  await scheduleNotifications();
  Workmanager().initialize(updateNotifications);
  Workmanager().registerPeriodicTask(
    "1",
    updateNotificationsTask,
    frequency: const Duration(minutes: 15),
  );
}

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
  FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);
  await localNotifications.initialize(initSettings);

  final databaseReference = FirebaseDatabase.instance.ref().child('activities');
  DatabaseEvent event = await databaseReference.once();

  Map<dynamic, dynamic> values = event.snapshot.value as Map<dynamic, dynamic>;
  List<ActivityModel> activities = [];
  values.forEach((key, value) {
    activities
        .add(ActivityModel.fromJson(key, Map<String, dynamic>.from(value)));
  });

  activities.sort((a, b) {
    DateTime dateA = parseTimeString(a.time!);
    DateTime dateB = parseTimeString(b.time!);
    return dateA.compareTo(dateB);
  });

  localNotifications.cancelAll();

  var counter = 0;

  for (ActivityModel activity in activities) {
    DateTime date = parseTimeString(activity.time!);
    DateTime? dateEndingTime = activity.endingTime != null
        ? parseTimeString(activity.endingTime!)
        : null;
    print("dateEndingTime" + dateEndingTime.toString());
    bool isAfter = date.isAfter(DateTime.now());
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    if (isAfter) {
      counter++;
      var difference = date.difference(DateTime.now());
      await localNotifications.zonedSchedule(
        counter,
        activity.name,
        'Es hora de empezar esta tarea!',
        tz.TZDateTime.now(tz.local).add(difference),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
    if (dateEndingTime != null) {
      const String actionKey = 'ACTION_KEY_REPLY';
      AndroidNotificationDetails androidNotificationDetails =
          const AndroidNotificationDetails('channel_id2', 'channel_name2',
              importance: Importance.max,
              priority: Priority.high,
              actions: [
            AndroidNotificationAction(
              actionKey,
              '',
              inputs: [
                AndroidNotificationActionInput(choices: ["Si", "No"])
              ],
            )
          ]);
      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      bool isAfter = dateEndingTime.isAfter(DateTime.now());
      if (isAfter) {
        var difference = dateEndingTime.difference(DateTime.now());
        await localNotifications.zonedSchedule(
          counter,
          activity.name,
          'Terminaste esta tarea?',
          tz.TZDateTime.now(tz.local).add(difference),
          notificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
  }
}
