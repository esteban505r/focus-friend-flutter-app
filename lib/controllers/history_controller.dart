import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/state/history_state.dart';

class HistoryController extends StateNotifier<HistoryState> {
  HistoryController()
      : super(HistoryState(
            year: DateTime.now().year, month: DateTime.now().month,activityId: ''));

  void setActivityId(String activityId) {
    state = state.copyWith(activityId: activityId);
  }
}
