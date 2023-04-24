class HistoryItemModel {
  String? activityId;
  DateTime? changedDateTime;
  String? newStatus;

  HistoryItemModel({
    this.activityId,
    this.changedDateTime,
    this.newStatus,
  });

  HistoryItemModel.fromJson(Map<String, dynamic> json) {
    changedDateTime = DateTime.parse(json['changed_date_time']);
    newStatus = json['new_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['changed_date_time'] = changedDateTime?.toIso8601String() ?? '';
    data['new_status'] = newStatus ?? '';
    return data;
  }
}






