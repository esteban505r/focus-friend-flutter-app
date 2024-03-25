import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/ui/pages/daily_page.dart';
import 'package:focus_friend/ui/pages/tasks_page.dart';

import '../../controllers/login_controller.dart';
import '../../state/provider/controllers/login_provider.dart';
import '../../state/provider/home_state_provider.dart';
import 'history_page.dart';
import 'home_page.dart';

class MainPage extends ConsumerWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(homeStateProvider);
    final pageController = PageController(initialPage: 0);
    LoginController loginController =
        ref.read(loginControllerProvider.notifier);
    return Scaffold(
        drawer: NavigationDrawer(
          children: [
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Cerrar sesion"),
              onTap: () async {
                await loginController.logOut();
              },
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(color: Colors.black),
          showUnselectedLabels: false,
          currentIndex: currentPage,
          onTap: (index) {
            ref.read(homeStateProvider.notifier).state = index;
            pageController.animateToPage(index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut);
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
                activeIcon: Icon(
                  Icons.home,
                  size: 30,
                )),
            BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Diarias'),
            BottomNavigationBarItem(icon: Icon(Icons.list_sharp), label: 'Tareas'),
            /*BottomNavigationBarItem(
                icon: Icon(Icons.history), label: 'Historial')*/
          ],
        ),
        body: Stack(
          children: [
            // ..._createBackgroundCircles(),
            PageView.builder(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, index) {
                switch (index) {
                  case 0:
                    return const HomePage();
                  case 1:
                    return const DailyPage();
                  case 2:
                    return const TasksPage();
                  case 3:
                    return const HistoryPage();
                  default:
                    return const SizedBox();
                }
              },
              itemCount: 4,
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
