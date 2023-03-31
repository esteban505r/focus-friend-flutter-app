import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatefulWidget {
  final String title;
  final String description;
  final String time;
  final bool completed;

  const TaskCard({
    Key? key,
    required this.title,
    required this.description,
    required this.time,
    required this.completed,
  }) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _completed = widget.completed;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _completed = !_completed;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _completed ? Colors.grey.shade300 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.quicksand(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.description,
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Builder(
                          builder: (context) {
                            var now = DateTime.now();
                            var hora = int.parse(widget.time.split(':')[0]);
                            var minutos = int.parse(widget.time.split(':')[1]);
                            return Text(
                              DateFormat('hh:mm a').format(DateTime(now.year,now.month,now.day,hora,minutos)),
                              style: GoogleFonts.quicksand(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // Checkbox(
            //   value: _completed,
            //   onChanged: (value) {
            //     setState(() {
            //       _completed = value!;
            //     });
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
