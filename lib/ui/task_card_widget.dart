import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/dto/activity_model.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';
import 'package:focus_friend/ui/pages/new_task_page.dart';
import 'package:focus_friend/ui/widgets/confirm_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/provider/controllers/task_controller.dart';
import '../task_status.dart';
import '../utils.dart';

class TaskCard extends ConsumerStatefulWidget {
  final Function(String) onTaskStateChanged;

  final ActivityModel task;

  const TaskCard(
      {Key? key, required this.task, required this.onTaskStateChanged})
      : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    TaskController controller =
        ref.read(taskController(widget.task.id ?? '').notifier);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.setSecondsRemaining(getSeconds(widget.task.time ?? ''));
      controller.start();
    });
    super.initState();
  }

  int getSeconds(String time) {
    try {
      var date = parseTimeString(time);
      Duration duration = date.difference(DateTime.now());
      if (!duration.isNegative) {
        return duration.inSeconds;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  String getTimeRemaining(int secondsRemaining) {
    final duration = Duration(seconds: secondsRemaining);
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskController(widget.task.id ?? ''));
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent),
            ),
            onExpansionChanged: (isExpanded) {
              setState(() {
                _isExpanded = isExpanded;
              });
            },
            title: Text(
              widget.task.name ?? '',
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.grey.shade800),
              ),
            ),
            subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    if (taskState.secondsRemaining > 0)
                     ...[
                       const Icon(
                         Icons.watch,
                         size: 17,
                         color: Colors.blue,
                       ),
                       const SizedBox(
                         width: 10,
                       ),
                       Text(
                         getTimeRemaining(taskState.secondsRemaining),
                         style: TextStyle(color: Colors.grey.shade800),
                       ),
                     ],
                    if (taskState.secondsRemaining <= 0)
                      Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: getStatusColor(widget.task.status.toString()),
                        ),
                        child: Text(
                          getStatus(widget.task.status.toString()),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white,fontSize: 13),
                        ),
                      ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(
                      Icons.watch_later_outlined,
                      size: 17,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      parse24to12(widget.task.time ?? ''),
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                )),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.network(
                          widget.task.image ?? '',
                          height: 100,
                          width: 100,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) {
                              return child;
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (_, ___, __) {
                            return Image.asset(
                              "assets/placeholder.png",
                              height: 100,
                            );
                          },
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          child: Text(
                            widget.task.description ?? '',
                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.task.status ==
                            TaskStatus.PENDING.toString()) ...<Widget>[
                          IconButton(
                            onPressed: () {
                              widget.onTaskStateChanged(
                                  TaskStatus.OMITTED.toString());
                            },
                            icon: Icon(
                              Icons.accessibility_new_sharp,
                              color: Colors.yellow[800],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        IconButton(
                          onPressed: () {
                            if (widget.task.status !=
                                TaskStatus.PENDING.toString()) {
                              widget.onTaskStateChanged(
                                  TaskStatus.PENDING.toString());
                            } else {
                              widget.onTaskStateChanged(
                                  TaskStatus.COMPLETED.toString());
                            }
                          },
                          icon: Icon(
                            widget.task.status == TaskStatus.PENDING.toString()
                                ? Icons.check_circle
                                : Icons.close,
                            color: widget.task.status ==
                                    TaskStatus.PENDING.toString()
                                ? Colors.green[800]
                                : Colors.red[800],
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewTaskPage(
                                          activityModel: widget.task,
                                        )));
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ConfirmDialog(
                                    message:
                                        "Estas seguro de que quieres eliminar esta tarea?",
                                    title: "Eliminar tarea",
                                    onConfirm: () {
                                      ActivityRepository()
                                          .deleteTask(widget.task.id ?? '');
                                    },
                                  );
                                });
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
