import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/activity_model.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';

final activityStreamProvider = StreamProvider.autoDispose<ActivityModel>((ref) {
  return ActivityRepository().getActivity();
});


