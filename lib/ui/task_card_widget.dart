import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/dto/activity_model.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';
import 'package:focus_friend/ui/pages/new_activity_page.dart';
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
  TaskCardState createState() => TaskCardState();
}

class TaskCardState extends ConsumerState<TaskCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskController);
    final now = taskState.dateTime;
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (parseTimeString(widget.task.time ?? "00:00")
                            .isAfter(now)) ...[
                          const Icon(
                            Icons.watch,
                            size: 17,
                            color: Colors.blue,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            getDuration(parseTimeString(widget.task.time ?? "00:00"),now),
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                        ],
                        if (parseTimeString(widget.task.time ?? "00:00")
                            .isBefore(now))
                          Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color:
                                  getStatusColor(widget.task.status.toString()),
                            ),
                            child: Text(
                              getStatus(widget.task.status.toString()),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.watch_later_outlined,
                          size: 17,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          parse24to12(widget.task.time ?? '00:00'),
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '-',
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                        ),
                        const Icon(
                          Icons.watch_later_outlined,
                          size: 17,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          parse24to12(widget.task.endingTime ?? '00:00'),
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ],
                    )
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
                                    builder: (context) => NewActivityPage(
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
                                          .deleteActivity(widget.task.id ?? '');
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
