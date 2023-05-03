import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/dto/history_day_item.dart';
import 'package:focus_friend/state/provider/controllers/history_provider.dart';
import 'package:focus_friend/state/state/history_state.dart';
import 'package:focus_friend/state/state/task_state.dart';
import 'package:focus_friend/task_status.dart';

import '../../../model/dto/history_item_model.dart';
import '../../../model/repositories/activity_repository.dart';

AutoDisposeFutureProviderFamily<List<HistoryDayItem?>, TaskStatus>
    historyItemsFutureProvider = FutureProvider.autoDispose
        .family<List<HistoryDayItem>, TaskStatus>((ref, status) async {
  HistoryState state = ref.read(historyControllerNotifierProvider);
  return ActivityRepository()
      .getActivityHistoryByMonthAndYear(month: state.month, year: state.year,byStatus: status);
});
