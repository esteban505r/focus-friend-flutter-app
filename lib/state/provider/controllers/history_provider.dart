import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/controllers/history_controller.dart';
import 'package:focus_friend/state/state/history_state.dart';

StateNotifierProvider<HistoryController,HistoryState> historyControllerNotifierProvider =
    StateNotifierProvider<HistoryController,HistoryState>((ref) => HistoryController());
