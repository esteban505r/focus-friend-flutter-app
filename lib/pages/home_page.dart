import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../provider/streams/activityStreamProvider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late AnimationController controller2;
  late AnimationController controller3;
  late AnimationController controller4;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    controller2 = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    controller3 = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    controller4 = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final activityStream = ref.watch(activityStreamProvider);
    int now = DateTime.now().hour;
    return activityStream.when(
        data: (data) => SafeArea(
              child: Scaffold(
                backgroundColor: Colors.grey.shade100,
                body: Stack(
                  children: [
                    Positioned(
                        top: -100,
                        right: -100,
                        child: Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              color: Color(0xFFEF9A53),
                            ))),
                    Positioned(
                        bottom: -50,
                        left: -50,
                        child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              color: Color(0xFFFDF7C3),
                            ))),
                    Positioned(
                        bottom: -50,
                        right: -50,
                        child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              color: Color(0xFFB2A4FF),
                            ))),
                    Positioned(
                        bottom: 200,
                        right: 20,
                        child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              color: Color(0xFFB0DAFF),
                            ))),
                    Positioned(
                        bottom: 300,
                        left: 10,
                        child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              color: Color(0xFF4D455D),
                            ))),
                    Positioned(
                        top: -50,
                        left: -50,
                        child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              color: Color(0xFFFFDEB4),
                            ))),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('h:mm a').format(parseTimeString(data.time!)),
                                    style: GoogleFonts.nunito(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff7C7C7C),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 30),
                                    child: Image.network(
                                      data.image ?? '',
                                      height: 200,
                                      errorBuilder: (_, ___, __) {
                                        return Image.asset(
                                          "assets/placeholder.png",
                                          height: 200,
                                        );
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data.name ?? '',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 23,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff222222),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50.0, vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          controller.forward().whenComplete(() {
                                            controller2
                                                .forward()
                                                .whenComplete(() {
                                              controller.reverse();
                                              controller2
                                                  .reverse()
                                                  .whenComplete(() {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            "Estas seguro que completaste esta tarea?"),
                                                        actions: [
                                                          TextButton(onPressed: (){
                                                            Navigator.pop(context);
                                                          }, child: Text("Si")),
                                                          TextButton(onPressed: (){}, child: Text("No"))
                                                        ],
                                                      );
                                                    });
                                              });
                                            });
                                          });
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(Colors
                                                    .greenAccent.shade100),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100)))),
                                        child: RotationTransition(
                                          turns: Tween<double>(
                                                  begin: 0.0, end: -0.1)
                                              .animate(CurvedAnimation(
                                                  parent: controller2,
                                                  curve: Curves.elasticOut)),
                                          child: RotationTransition(
                                            turns: Tween<double>(
                                                    begin: 0, end: 0.05)
                                                .animate(CurvedAnimation(
                                                    parent: controller,
                                                    curve: Curves.elasticOut)),
                                            child: Image.asset(
                                              'assets/happy.png',
                                              height: 70,
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          controller3
                                              .forward()
                                              .whenComplete(() {
                                            controller4
                                                .forward()
                                                .whenComplete(() {
                                              controller3.reverse();
                                              controller4.reverse();
                                            });
                                          });
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.red.shade200),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100)))),
                                        child: RotationTransition(
                                          turns: Tween<double>(
                                                  begin: 0.0, end: -0.2)
                                              .animate(CurvedAnimation(
                                                  parent: controller4,
                                                  curve: Curves.easeInOut)),
                                          child: RotationTransition(
                                            turns: Tween<double>(
                                                    begin: 0, end: 0.1)
                                                .animate(CurvedAnimation(
                                                    parent: controller3,
                                                    curve: Curves.easeInOut)),
                                            child: Image.asset(
                                              'assets/crying.png',
                                              height: 70,
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        error: (error, stacktrace) {
          debugPrint(error.toString());
          return Center(child: Text("ERROR"));
        },
        loading: () => Center(
              child: CircularProgressIndicator(),
            ));
  }

  Widget buildButton(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
          backgroundColor: MaterialStateProperty.all<Color>(color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xff333333),
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
