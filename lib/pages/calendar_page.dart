import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/utils.dart';
import 'package:google_fonts/google_fonts.dart';

import '../provider/streams/activitiesStreamProvider.dart';
import '../task_status.dart';
import '../ui/task_card_widget.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final activitiesStream = ref.watch(activitiesStreamProvider);
    return  activitiesStream.when(
      data: (data)=>SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text("Tareas",style: GoogleFonts.quicksand(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10),
                    child: TaskCard(
                      title: data[index].name ?? '',
                      description:
                      data[index].description ?? '',
                      timeRemaining: parseTimeString(data[index].time??''),
                      imagePath: data[index].image??'',
                      status: TaskStatus.fromString(data[index].status??''),
                    ),
                  );
                },
                itemCount: data.length,
              ),
            ),
          ],
        ),
      ),
        error: (error, stack) {
          debugPrint(error.toString());
          return const Text("ERROR");
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        )
    );
  }
}
