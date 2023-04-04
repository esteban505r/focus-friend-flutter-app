import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/pages/base_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:focus_friend/utils.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz2;
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
  tz2.initializeTimeZones();
  await scheduleNotifications();
  Workmanager().initialize(updateNotifications);
  Workmanager().registerPeriodicTask(
    "1",
    updateNotificationsTask,
    frequency: Duration(minutes: 15),
  );

  runApp(const ProviderScope(
    child: MyApp(),
  ));
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
  FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initSettings = InitializationSettings(android: androidInitSettings);
  await localNotifications.initialize(initSettings);

  final databaseReference = FirebaseDatabase.instance.ref().child('activities');
  DatabaseEvent event = await databaseReference.once();

  Map<dynamic, dynamic> values =
  event.snapshot.value as Map<dynamic, dynamic>;
  List<ActivityModel> activities = [];
  values.forEach((key, value) {
    activities
        .add(ActivityModel.fromJson(key,Map<String, dynamic>.from(value)));
  });

  activities.sort((a, b) {
    DateTime dateA = parseTimeString(a.time!);
    DateTime dateB = parseTimeString(b.time!);
    return dateA.compareTo(dateB);
  });

  localNotifications.cancelAll();

  var counter =0;

  for(ActivityModel activity in activities) {
    DateTime date = parseTimeString(activity.time!);
    bool isAfter = date.isAfter(DateTime.now());
    if (isAfter) {
      counter++;
      AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
        'channel_id', 'channel_name',
        importance: Importance.max,
        priority: Priority.high,
      );
      NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails);
      var difference =  date.difference(DateTime.now());
      await localNotifications.zonedSchedule(
        counter,
        activity.name,
        'Es hora de empezar esta tarea!',
        tz.TZDateTime.now(tz.local).add(
          difference
        ),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
            .absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}

