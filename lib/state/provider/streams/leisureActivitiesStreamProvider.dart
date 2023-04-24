import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/dto/leisure_activity_model.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';

final leisureActivitiesStreamProvider =
    StreamProvider.autoDispose<List<LeisureActivityModel>>((ref) {
  return ActivityRepository().getLeisure();
});

