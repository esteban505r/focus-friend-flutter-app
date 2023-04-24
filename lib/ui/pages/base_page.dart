import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/ui/pages/tasks_page.dart';

import '../../state/provider/home_state_provider.dart';
import 'history_page.dart';
import 'home_page.dart';

class BasePage extends ConsumerWidget {
  const BasePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(homeStateProvider);
    final pageController = PageController(initialPage: 0);
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          selectedLabelStyle: TextStyle(color: Colors.black),
          showUnselectedLabels: false,
          currentIndex: currentPage,
          onTap: (index) {
            ref.read(homeStateProvider.notifier).state = index;
            pageController.animateToPage(index,
                duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
                activeIcon: Icon(
                  Icons.home,
                  size: 30,
                )),
            BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tareas'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: 'Historial')
          ],
        ),
        body: Stack(
          children: [
            // ..._createBackgroundCircles(),
            PageView.builder(
              controller: pageController,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (_, index) {
                switch (index) {
                  case 0:
                    return HomePage();
                  case 1:
                    return CalendarPage();
                  case 2:
                    return HistoryPage();
                  default:
                    return SizedBox();
                }
              },
              itemCount: 3,
            ),
          ],
        ));
  }

  List<Widget> _createBackgroundCircles() {
    return <Widget>[
      Positioned(
          top: -100,
          right: -100,
          child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                color: const Color(0xFFEF9A53),
              ))),
      // Positioned(
      //     bottom: -50,
      //     left: -50,
      //     child: Container(
      //         height: 120,
      //         width: 120,
      //         decoration: BoxDecoration(
      //           borderRadius: BorderRadius.circular(200),
      //           color: const Color(0xFFFDF7C3),
      //         ))),
      // Positioned(
      //     bottom: -50,
      //     right: -50,
      //     child: Container(
      //         height: 150,
      //         width: 150,
      //         decoration: BoxDecoration(
      //           borderRadius: BorderRadius.circular(200),
      //           color: const Color(0xFFB2A4FF),
      //         ))),
      Positioned(
          bottom: 200,
          right: 20,
          child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                color: const Color(0xFFB0DAFF),
              ))),
      Positioned(
          bottom: 300,
          left: 10,
          child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                color: const Color(0xFF4D455D),
              ))),
      Positioned(
          top: -50,
          left: -50,
          child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                color: const Color(0xFFFFDEB4),
              ))),
    ];
  }
}
