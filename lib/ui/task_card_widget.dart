import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/time_notifier.dart';
import '../task_status.dart';
import '../utils.dart';

class TaskCard extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final TaskStatus status;
  final String imagePath;
  final String time;
  final String id;

  const TaskCard(this.id, {
    Key? key,
    required this.title,
    required this.description,
    required this.status,
    required this.imagePath,
    required this.time,
  }) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    TaskController controller = ref.read(taskController(widget.id).notifier);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.setSecondsRemaining(getSeconds(widget.time));
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
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration
        .inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60)
        .toString()
        .padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskController(widget.id));
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
              widget.title,
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey.shade800),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: taskState.secondsRemaining > 0 ? Row(
                children: [
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
                    style: TextStyle(color: Colors.grey.shade800),),
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
                    parse24to12(widget.time),
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ],
              ) : Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: getStatusColor(taskState.status.toString()),
                ),
                child: Text(
                  getStatus(taskState.status.toString()),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
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
                          widget.imagePath,
                          height: 100,
                          width: 100,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) {
                              return child;
                            }
                            return const Center(
                              child: CircularProgressIndicator(),);
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
                            widget.description,
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
                        IconButton(
                          onPressed: () {
                            // Implementar la función de eliminar
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            // Implementar la función de eliminar
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
