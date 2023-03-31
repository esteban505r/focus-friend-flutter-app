import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/activity_model.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';

final activityStreamProvider = StreamProvider.autoDispose<ActivityModel>((ref) {
  final activityRepository = ref.read(activityRepositoryProvider);
  return activityRepository.getActivity();
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});