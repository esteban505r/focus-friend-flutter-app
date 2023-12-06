import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';
import 'package:focus_friend/state/provider/streams/tasksStreamProvider.dart';
import 'package:focus_friend/task_status.dart';
import 'package:focus_friend/ui/pages/new_task_page.dart';

import '../../utils.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskStream = ref.watch(tasksStreamProvider);
    return taskStream.when(
        data: (data) => Scaffold(
              body: SafeArea(
                child: Stack(
                  children: [
                    if (data.isEmpty)
                      Center(
                          child: Text(
                        "No tienes tareas, crea una!",
                        style: Theme.of(context).textTheme.titleLarge,
                      )),
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                          child: Text(
                            "Tareas",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 16),
                                child: Card(
                                  child: ListTile(
                                    minLeadingWidth: 0,
                                    leading: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                        child: Checkbox(
                                          activeColor:
                                              Theme.of(context).primaryColor,
                                          onChanged: (v) {
                                            ActivityRepository().updateTaskStatus(data[index].id??"", v??false);
                                          },
                                          value: TaskStatus.COMPLETED ==
                                              TaskStatus.fromString(
                                                  data[index].status??"pending"),
                                        ),
                                      ),
                                    ),
                                    title:
                                        Text(data[index].name ?? "Sin nombre"),
                                    subtitle: buildDaysLeft(
                                        getDaysLeftToCompleteATask(
                                            data[index].deadline)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NewTaskPage()));
                },
                child: const Icon(Icons.add),
              ),
            ),
        error: (error, stack) {
          debugPrint(error.toString());
          return const Text("ERROR");
        },
        loading: () => const Center(
              child: CircularProgressIndicator(),
            ));
  }
}
