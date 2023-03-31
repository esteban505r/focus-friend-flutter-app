import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/pages/calendar_page.dart';
import 'package:focus_friend/provider/home_state_provider.dart';

import 'home_page.dart';

class BasePage extends ConsumerWidget {
  const BasePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(homeStateProvider);
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Color(0xff7F9C8D),
          selectedLabelStyle: TextStyle(color: Colors.black),
          showUnselectedLabels: false,
          currentIndex: currentPage=='calendar'?1:0,
          onTap: (index){
            if(index==0){
              ref.read(homeStateProvider.notifier).state = 'home';
              return;
            }
            ref.read(homeStateProvider.notifier).state = 'calendar';
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: "Home",activeIcon: Icon(Icons.home,size: 30,) ),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: 'Calendario'),
          ],
        ),
        backgroundColor: Colors.blue.shade400,
        body: Builder(builder: (_){
          switch(currentPage){
            case "calendar": return CalendarPage();
            case "home": return HomePage();
            default:
              return SizedBox();
          }
        },));
  }
}
