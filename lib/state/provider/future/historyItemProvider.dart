import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/state/provider/controllers/history_provider.dart';
import 'package:focus_friend/state/state/history_state.dart';

import '../../../model/dto/history_item_model.dart';
import '../../../model/repositories/activity_repository.dart';

AutoDisposeFutureProviderFamily<List<HistoryItemModel>, String>
    historyFutureProvider = FutureProvider.autoDispose
        .family<List<HistoryItemModel>, String>((ref, id) async {
  HistoryState state = ref.read(historyControllerNotifierProvider);
  return ActivityRepository().getActivityHistoryByMonthAndYear(id,
      month: state.month, year: state.year);
});
