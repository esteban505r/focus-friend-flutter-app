import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';

import '../../state/provider/streams/activitiesStreamProvider.dart';
import '../task_card_widget.dart';
import 'new_task_page.dart';

class TaskPage extends ConsumerWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesStream = ref.watch(activitiesStreamProvider);
    return activitiesStream.when(
        data: (data) =>
            SafeArea(
              child: Stack(
                children: [
                  if(data.isEmpty)
                  Center(child: Text("No tienes actividades, crea una!",style: Theme.of(context).textTheme.titleLarge,)),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0,bottom: 20),
                        child: Text(
                          "Tareas",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20,left: 20,right: 20),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: TaskCard(
                                task: data[index],
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
                            builder: (context) => const NewTaskPage()));
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
