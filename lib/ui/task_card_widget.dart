import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../task_status.dart';

class TaskCard extends StatefulWidget {
  final String title;
  final String description;
  final String timeRemaining;
  final TaskStatus status;
  final String imagePath;

  const TaskCard({
    Key? key,
    required this.title,
    required this.description,
    required this.timeRemaining,
    required this.status,
    required this.imagePath,
  }) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isExpanded = false;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: ExpansionTile(
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
            subtitle: Text(
              widget.timeRemaining,
              style: TextStyle(color: Colors.grey.shade800),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.network(
                          widget.imagePath,
                          height: 100,
                        ),
                        SizedBox(
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
                          icon: Icon(Icons.edit,color: Colors.blue[800],),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            // Implementar la función de eliminar
                          },
                          icon: Icon(Icons.delete,color: Colors.red,),
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
