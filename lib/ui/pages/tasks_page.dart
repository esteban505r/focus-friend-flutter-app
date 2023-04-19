import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../provider/streams/activitiesStreamProvider.dart';
import '../../task_status.dart';
import '../task_card_widget.dart';
import 'new_task_page.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesStream = ref.watch(activitiesStreamProvider);
    return activitiesStream.when(
        data: (data) =>
            SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          "Tareas",
                          style: GoogleFonts.quicksand(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: TaskCard(
                                data[index].id ?? '',
                                title: data[index].name ?? '',
                                description: data[index].description ?? '',
                                time: data[index].time ?? '',
                                imagePath: data[index].image ?? '',
                                status: TaskStatus.fromString(
                                    data[index].status ?? ''),
                                onTaskStateChanged: (state) {
                                  ActivityRepository()
                                      .updateStatus(data[index].time!, state);
                                },
                              ),
                            );
                          },
                          itemCount: data.length,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => NewTaskPage()));
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
        error: (error, stack) {
          debugPrint(error.toString());
          return const Text("ERROR");
        },
        loading: () =>
        const Center(
          child: CircularProgressIndicator(),
        ));
  }
}
