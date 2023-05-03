import 'package:focus_friend/model/dto/history_item_model.dart';

class HistoryDayItem{
  List<HistoryItemModel> historyList;
  DateTime dateTime;

  HistoryDayItem({required this.historyList, required this.dateTime});
}