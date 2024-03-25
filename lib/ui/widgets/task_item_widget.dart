import 'package:flutter/material.dart';
import 'package:focus_friend/model/dto/task_model.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';
import 'package:focus_friend/task_status.dart';
import 'package:focus_friend/ui/pages/new_task_page.dart';
import 'package:focus_friend/ui/pages/task_detail_page.dart';
import 'package:focus_friend/utils.dart';

class TaskItemWidget extends StatelessWidget {
  const TaskItemWidget(this.taskModel, {super.key});

  final TaskModel taskModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
      child: Dismissible(
        onDismissed: (value) {
          if (value == DismissDirection.endToStart) {
            ActivityRepository().deleteTask(taskModel.id ?? "");
          }
        },
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NewTaskPage(
                          taskModel: taskModel,
                        )));
          }
          return direction == DismissDirection.endToStart;
        },
        key: UniqueKey(),
        background: Container(
          color: Colors.blue,
          alignment: Alignment.centerLeft,
          child: const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          child: const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              minLeadingWidth: 0,
              leading: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (v) {
                    ActivityRepository()
                        .updateTaskStatus(taskModel.id ?? "", v ?? false);
                  },
                  value: TaskStatus.COMPLETED ==
                      TaskStatus.fromString(taskModel.status ?? "pending"),
                ),
              ),
              title: Text(taskModel.name ?? "Sin nombre"),
              subtitle: TaskStatus.fromString(taskModel.status ?? "pending") ==
                      TaskStatus.COMPLETED
                  ? const Text(
                      "Completado",
                      style: TextStyle(color: Colors.green),
                    )
                  : buildDaysLeft(getDaysLeftToCompleteATask(taskModel.deadline)),
              trailing: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 14,
                  ),
                  onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>TaskDetailPage(taskModel)));
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
