import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/activity_model.dart';
import 'package:focus_friend/model/leisure_activity_model.dart';
import '../../model/repositories/activity_repository.dart';
import 'activitiesStreamProvider.dart';

final leisureActivitiesStreamProvider =
    StreamProvider.autoDispose<List<LeisureActivityModel>>((ref) {
  final activitiesRepository = ref.read(activitiesRepositoryProvider);
  return activitiesRepository.getLeisure();
});

