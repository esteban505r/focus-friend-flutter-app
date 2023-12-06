import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/dto/task_model.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';

final tasksStreamProvider = StreamProvider.autoDispose<List<TaskModel>>((ref) {
  return ActivityRepository().getStreamTasks();
});

