import 'package:flutter/material.dart';
import 'package:focus_friend/model/dto/task_model.dart';
import 'package:intl/intl.dart';

class TaskDetailPage extends StatelessWidget {

  const TaskDetailPage(this.task,{super.key});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(task.name??""),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(task.description??""),
            SizedBox(height: 16.0),
            Text('Fecha límite:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(DateFormat.yMMMd().format(DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(task.deadline??""))),
          ],
        ),
      ),
    );
  }
}
