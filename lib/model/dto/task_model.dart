import 'package:focus_friend/state/state/task_state.dart';

import '../../task_status.dart';

class TaskModel {
  String? id;
  String? extraText;
  String? name;
  String? deadline;
  String? description;
  String? status;
  String? image;
  String? lastUpdate;

  TaskModel({
    this.id,
    this.extraText,
    this.name,
    this.deadline,
    this.description,
    this.image,
    this.status,
    this.lastUpdate,
  });

  TaskModel.fromJson(String this.id, Map<String, dynamic> json) {
    extraText = json['extraText'];
    name = json['name'];
    deadline = json['deadline'];
    description = json['description'];
    image = json['image'];
    status = json['status'];
    lastUpdate = json['last_update'];

    try {
      DateTime date = DateTime.parse(lastUpdate ?? '');
      if (date.day < DateTime.now().day || date.month < DateTime.now().month) {
        status = 'pending';
      }
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['extraText'] = extraText ?? '';
    data['name'] = name ?? '';
    data['deadline'] = deadline ?? '00:00';
    data['description'] = description ?? '';
    data['image'] = image ?? '';
    data['status'] = status ?? TaskStatus.PENDING.toString();
    data['last_update'] = lastUpdate ?? DateTime.now().toIso8601String();
    return data;
  }
}
