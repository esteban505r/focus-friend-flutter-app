import 'package:firebase_database/firebase_database.dart';
import 'package:focus_friend/model/dto/activity_model.dart';
import 'package:focus_friend/model/dto/history_item_model.dart';
import 'package:focus_friend/model/dto/leisure_activity_model.dart';
import 'package:focus_friend/utils.dart';

import '../../utils/notifications.dart';

class ActivityRepository {
  ActivityRepository._privateConstructor();

  static final ActivityRepository _instance =
      ActivityRepository._privateConstructor();

  factory ActivityRepository() {
    return _instance;
  }

  Future<void> updateStatus(String hour, String status) async {
    DatabaseReference objectsRef =
        FirebaseDatabase.instance.ref().child("activities");
    Query query = objectsRef.orderByChild("time").equalTo(hour);

    var result = await query.once();
    if (result.snapshot.value != null) {
      Map<dynamic, dynamic> values = Map<dynamic, dynamic>.from(
          result.snapshot.value as Map<Object?, Object?>);
      String objectId = values.keys.first;
      objectsRef.child(objectId).update(
          {"status": status, "last_update": DateTime.now().toIso8601String()});
      updateHistoryStatus(objectId, status);
    }
  }

  Future<void> addTask(ActivityModel activityModel) async {
    DatabaseReference objectsRef =
        FirebaseDatabase.instance.ref().child("activities");
    await objectsRef.push().set(activityModel.toJson());
    await scheduleNotifications();
  }

  Stream<ActivityModel> getActivity() {
    DatabaseReference ref = FirebaseDatabase.instance.ref();

    return ref.child('activities').onValue.map((event) {
      Map<dynamic, dynamic> values =
          event.snapshot.value as Map<dynamic, dynamic>;
      List<dynamic> filteredValues = values.values.where((activity) {
        DateTime activityTime = parseTimeString(activity['time']);
        DateTime now = DateTime.now();
        return activityTime.hour <= now.hour ||
            (activityTime.hour == now.hour &&
                activityTime.minute <= now.minute);
      }).toList();

      if (filteredValues.isNotEmpty) {
        Map<Object?, Object?> latestActivity =
            filteredValues.reduce((curr, next) {
          DateTime currTime = parseTimeString(curr['time']);
          DateTime nextTime = parseTimeString(next['time']);

          return (currTime.isAfter(nextTime)) ? curr : next;
        });

        return ActivityModel.fromJson(
            "", Map<String, dynamic>.from(latestActivity));
      } else {
        return ActivityModel();
      }
    });
  }

  Stream<List<ActivityModel>> getActivities() {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    return ref.child('activities').onValue.map((event) {
      Map<dynamic, dynamic> values =
          event.snapshot.value as Map<dynamic, dynamic>;
      List<ActivityModel> activities = [];
      values.forEach((key, value) {
        activities
            .add(ActivityModel.fromJson(key, Map<String, dynamic>.from(value)));
      });
      activities.sort((a, b) {
        DateTime dateA = parseTimeString(a.time!);
        DateTime dateB = parseTimeString(b.time!);
        return dateA.compareTo(dateB);
      });
      return activities;
    });
  }

  Stream<List<LeisureActivityModel>> getLeisure() {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    return ref.child('leisure').onValue.map((event) {
      Map<dynamic, dynamic> values =
          event.snapshot.value as Map<dynamic, dynamic>;
      List<LeisureActivityModel> activities = [];
      values.forEach((key, value) {
        activities.add(
            LeisureActivityModel.fromJson(Map<String, dynamic>.from(value)));
      });
      activities.shuffle();
      return activities;
    });
  }

  Future<void> deleteTask(String id) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    await ref.child('activities').child(id).remove();
    await scheduleNotifications();
  }

  Future<void> editTask(ActivityModel activityModel) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    if (activityModel.id != null) {
      await ref
          .child('activities')
          .child(activityModel.id!)
          .set(activityModel.toJson());
      await scheduleNotifications();
    }
  }

  Future<List<HistoryItemModel>> getActivityHistoryByMonthAndYear(
      String id, {required int month, required int year}) async {
    final databaseRef = FirebaseDatabase.instance.ref();
    final historyRef = databaseRef
        .child('history')
        .child(year.toString())
        .child(month.toString());

    final event = await historyRef.once();
    final activityHistory = <HistoryItemModel>[];
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> values =
          event.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((dayKey, dayValue) {
        dayValue.forEach((historyKey, historyValue) {
          if(historyKey==id){
            activityHistory.add(HistoryItemModel.fromJson(Map<String, dynamic>.from(historyValue)));
          }
        });
      });
    }
    activityHistory.sort((a,b)=>a.changedDateTime!.day.compareTo(b.changedDateTime!.day));


    return activityHistory;
  }

  Future<void> updateHistoryStatus(
    String id,
    String status,
  ) async {
    DatabaseReference objectsRef = FirebaseDatabase.instance
        .ref()
        .child('history')
        .child(DateTime.now().year.toString())
        .child(DateTime.now().month.toString())
        .child(DateTime.now().day.toString())
        .child(id);
    await objectsRef.set(HistoryItemModel(
            activityId: id, changedDateTime: DateTime.now(), newStatus: status)
        .toJson());
  }
}
