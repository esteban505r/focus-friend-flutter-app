import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:focus_friend/state/provider/streams/loggedStreamProvider.dart';
import 'package:focus_friend/ui/pages/base_page.dart';
import 'package:focus_friend/ui/pages/home_page.dart';
import 'package:focus_friend/ui/pages/login_page.dart';
import 'package:focus_friend/ui/pages/questions_page.dart';
import 'package:focus_friend/utils/notifications.dart';
import 'package:focus_friend/utils/preferences.dart';

import 'firebase_options.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesManager().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if(FirebaseAuth.instance.currentUser!=null) {
    await initializeNotifications();
  }

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUserLogged = ref.watch(loggedStreamProvider);
    return MaterialApp(
      title: 'Focus Friend',
      theme: ThemeData(
          colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFFF57C00),
              secondary: const Color(0xff0288D1),
              tertiary: const Color(0xFF616161),
              background: const Color(0xFFF5F5F5))),
      home: isUserLogged.when(
          data: (user) {
            if(user==null){
              return LoginPage();
            }
            return QuestionsPage();
          },
          error: (error, _) {
            print(error);
            return const SizedBox.shrink();
          },
          loading: () => Scaffold(body: Center(child: const CircularProgressIndicator()))),
    );
  }
}
