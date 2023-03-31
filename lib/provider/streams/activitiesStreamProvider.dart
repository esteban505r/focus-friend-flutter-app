import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/activity_model.dart';
import '../../model/repositories/activity_repository.dart';

final activitiesStreamProvider = StreamProvider.autoDispose<List<ActivityModel>>((ref) {
  final activitiesRepository = ref.read(activitiesRepositoryProvider);
  return activitiesRepository.getActivities();
});

final activitiesRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});
