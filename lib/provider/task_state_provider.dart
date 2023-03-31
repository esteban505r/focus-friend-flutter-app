import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/task_state.dart';

final taskStateProvider = StateProvider((ref) => TaskState());