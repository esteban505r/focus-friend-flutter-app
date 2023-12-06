import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:focus_friend/model/dto/activity_model.dart';
import 'package:focus_friend/model/dto/history_day_item.dart';
import 'package:focus_friend/model/dto/history_item_model.dart';
import 'package:focus_friend/model/dto/leisure_activity_model.dart';
import 'package:focus_friend/model/dto/task_model.dart';
import 'package:focus_friend/utils.dart';

import '../../task_status.dart';
import '../../utils/notifications.dart';

class ActivityRepository {
  ActivityRepository._privateConstructor();

  static final ActivityRepository _instance =
      ActivityRepository._privateConstructor();

  factory ActivityRepository() {
    return _instance;
  }

  Future<bool> checkIfActivityCanBe(ActivityModel activityModel) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await ref
        .child('usuarios')
        .child(currentUser!.uid)
        .child('activities')
        .once();

    Map<dynamic, dynamic>? values =
        event.snapshot.value as Map<dynamic, dynamic>?;
    List<ActivityModel?> activities = [];
    values?.forEach((key, value) {
      activities
          .add(ActivityModel.fromJson(key, Map<String, dynamic>.from(value)));
    });

    TimeOfDay startingTime = parseTimeOfDay(activityModel.time ?? '00:00');
    TimeOfDay endingTime = parseTimeOfDay(activityModel.endingTime ?? '00:00');

    for (int i = 0; i < (activities.length ?? 0); i++) {
      TimeOfDay startingElementTime =
          parseTimeOfDay(activities[i]?.time ?? '00:00');
      TimeOfDay endingElementTime =
          parseTimeOfDay(activities[i]?.endingTime ?? '00:00');

      int startingCompareEnding = startingTime.compareTo(endingElementTime);
      int endingCompareStarting = endingTime.compareTo(startingElementTime);

      if (activityModel.id == activities[i]?.id) {
        continue;
      }

      if (startingCompareEnding >= 0 || endingCompareStarting <= 0) {
        continue;
      }
      return false;
    }
    return true;
  }

  Future<void> updateActivityStatus(String hour, String status) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference objectsRef = FirebaseDatabase.instance
        .ref()
        .child('usuarios')
        .child(currentUser!.uid)
        .child("activities");
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


  Stream<List<TaskModel>> getStreamTasks() {
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    return ref
        .child('usuarios')
        .child(currentUser!.uid)
        .child('tasks')
        .onValue
        .map((event) {
      Map<dynamic, dynamic>? values =
      event.snapshot.value as Map<dynamic, dynamic>?;
      List<TaskModel> tasks = [];
      values?.forEach((key, value) {
        tasks
            .add(TaskModel.fromJson(key, Map<String, dynamic>.from(value)));
      });
      tasks.sort((a, b) {
        DateTime dateA = parseDateString(a.deadline!);
        DateTime dateB = parseDateString(b.deadline!);
        return dateA.compareTo(dateB);
      });
      return tasks;
    });
  }

  Future<List<TaskModel>> getTasks() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await ref
        .child('usuarios')
        .child(currentUser!.uid)
        .child('tasks')
        .once();

    Map<dynamic, dynamic>? values =
    event.snapshot.value as Map<dynamic, dynamic>?;
    List<TaskModel> tasks = [];
    values?.forEach((key, value) {
      tasks
          .add(TaskModel.fromJson(key, Map<String, dynamic>.from(value)));
    });
    tasks.sort((a, b) {
      DateTime dateA = parseDateString(a.deadline!);
      DateTime dateB = parseDateString(b.deadline!);
      return dateA.compareTo(dateB);
    });
    return tasks;
  }
  
  Future<void> addTask(TaskModel taskModel) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference objectsRef = FirebaseDatabase.instance
        .ref()
        .child('usuarios')
        .child(currentUser!.uid)
        .child("tasks");
    await objectsRef.push().set(taskModel.toJson());
    await scheduleNotifications();
  }
  

  Future<void> addActivity(ActivityModel activityModel) async {
    bool canBe = await checkIfActivityCanBe(activityModel);
    if (!canBe) {
      throw 'La actividad que deseas agregar esta en o entre el mismo horario que otra';
    }
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference objectsRef = FirebaseDatabase.instance
        .ref()
        .child('usuarios')
        .child(currentUser!.uid)
        .child("activities");
    await objectsRef.push().set(activityModel.toJson());
    await scheduleNotifications();
  }

  Stream<ActivityModel?> getActivity() {
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    return ref
        .child('usuarios')
        .child(currentUser!.uid)
        .child('activities')
        .onValue
        .map((event) {
      Map<dynamic, dynamic>? values =
          event.snapshot.value as Map<dynamic, dynamic>?;
      Map<Object?, Object?>? filteredValues =
          values?.values.firstWhere((activity) {
        TimeOfDay startingTime = parseTimeOfDay(activity['time']);
        TimeOfDay endingTime = parseTimeOfDay(activity['ending_time']);
        TimeOfDay now = TimeOfDay.now();
        return startingTime.compareTo(now) <= 0 &&
            endingTime.compareTo(now) >= 0;
      }, orElse: () => null);

      if (filteredValues != null) {
        return ActivityModel.fromJson(
            "", Map<String, dynamic>.from(filteredValues));
      }
      return null;
    });
  }

  Future<void> updateTaskStatus(String id,bool status) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference objectsRef = FirebaseDatabase.instance
        .ref()
        .child('usuarios')
        .child(currentUser!.uid)
        .child("tasks").child(id);

    var result = await objectsRef.once();
    if (result.snapshot.value != null) {
      objectsRef.update(
          {"status": status ? "completed" : "pending", "last_update": DateTime.now().toIso8601String()});
    }
  }


  Stream<List<ActivityModel>> getStreamActivities() {
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    return ref
        .child('usuarios')
        .child(currentUser!.uid)
        .child('activities')
        .onValue
        .map((event) {
      Map<dynamic, dynamic>? values =
          event.snapshot.value as Map<dynamic, dynamic>?;
      List<ActivityModel> activities = [];
      values?.forEach((key, value) {
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

  Future<List<ActivityModel>> getActivities() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await ref
        .child('usuarios')
        .child(currentUser!.uid)
        .child('activities')
        .once();

    Map<dynamic, dynamic>? values =
        event.snapshot.value as Map<dynamic, dynamic>?;
    List<ActivityModel> activities = [];
    values?.forEach((key, value) {
      activities
          .add(ActivityModel.fromJson(key, Map<String, dynamic>.from(value)));
    });
    activities.sort((a, b) {
      DateTime dateA = parseTimeString(a.time!);
      DateTime dateB = parseTimeString(b.time!);
      return dateA.compareTo(dateB);
    });
    return activities;
  }

  Stream<List<LeisureActivityModel>> getLeisure() {
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    return ref
        .child('usuarios')
        .child(currentUser!.uid)
        .child('leisure')
        .onValue
        .map((event) {
      Map<dynamic, dynamic>? values =
          event.snapshot.value as Map<dynamic, dynamic>?;
      List<LeisureActivityModel> activities = [];
      values?.forEach((key, value) {
        activities.add(
            LeisureActivityModel.fromJson(Map<String, dynamic>.from(value)));
      });
      activities.shuffle();
      return activities;
    });
  }

  Future<void> deleteActivity(String id) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    await ref
        .child('usuarios')
        .child(currentUser!.uid)
        .child('activities')
        .child(id)
        .remove();
    await scheduleNotifications();
  }

  Future<void> deleteTask(String id) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    await ref
        .child('usuarios')
        .child(currentUser!.uid)
        .child('tasks')
        .child(id)
        .remove();
  }

  Future<void> editActivity(ActivityModel activityModel) async {
    bool canBe = await checkIfActivityCanBe(activityModel);
    if (!canBe) {
      throw 'La actividad que deseas editar esta en o entre el mismo horario que otra';
    }
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    if (activityModel.id != null) {
      await ref
          .child('usuarios')
          .child(currentUser!.uid)
          .child('activities')
          .child(activityModel.id!)
          .set(activityModel.toJson());
      await scheduleNotifications();
    }
  }

  Future<List<HistoryDayItem>> getActivityHistoryByMonthAndYear(
      {required int month, required int year, TaskStatus? byStatus}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final databaseRef = FirebaseDatabase.instance.ref();
    final historyRef = databaseRef
        .child('usuarios')
        .child(currentUser!.uid)
        .child('history')
        .child("year-${year.toString()}")
        .child("month-${month.toString()}");

    List<ActivityModel> activities = await getActivities();
    List<HistoryDayItem> history = [];

    final event = await historyRef.once();
    final activityHistory = <HistoryItemModel?>[];
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> values =
          event.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((dayKey, dayValue) {
        dayValue.forEach((historyKey, historyValue) {
          activityHistory.add(HistoryItemModel.fromJson(
              Map<String, dynamic>.from(historyValue)));
        });
      });
    }
    activityHistory.sort(
        (a, b) => a!.changedDateTime!.day.compareTo(b!.changedDateTime!.day));

    for (int i = 1; i < 31; i++) {
      List<HistoryItemModel> historyList = [];
      for (ActivityModel activity in activities) {
        HistoryItemModel? item = activityHistory.firstWhere(
            (element) =>
                activity.id == element?.activityId &&
                element?.changedDateTime?.day == i,
            orElse: () => HistoryItemModel(
                changedDateTime: DateTime(year, month, i),
                activityId: activity.id,
                newStatus: TaskStatus.PENDING.toString()));
        if (byStatus != null) {
          if (item?.newStatus.toString() == byStatus.toString()) {
            historyList.add(item!);
          }
          continue;
        }
        historyList.add(item!);
      }
      HistoryDayItem historyDayItem = HistoryDayItem(
          historyList: historyList, dateTime: DateTime(year, month, i));
      history.add(historyDayItem);
    }
    return history;
  }

  Future<List<HistoryItemModel>> getActivityHistoryByMonthAndYearAndId(
      String id,
      {required int month,
      required int year}) async {
    if (id.isEmpty) {
      return [];
    }
    final currentUser = FirebaseAuth.instance.currentUser;
    final databaseRef = FirebaseDatabase.instance.ref();
    final historyRef = databaseRef
        .child('usuarios')
        .child(currentUser!.uid)
        .child('history')
        .child("year-${year.toString()}")
        .child("month-${month.toString()}");

    final event = await historyRef.once();
    final activityHistory = <HistoryItemModel>[];
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> values =
          event.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((dayKey, dayValue) {
        dayValue.forEach((historyKey, historyValue) {
          if (historyKey == id) {
            activityHistory.add(HistoryItemModel.fromJson(
                Map<String, dynamic>.from(historyValue)));
          }
        });
      });
    }
    activityHistory.sort(
        (a, b) => a.changedDateTime!.day.compareTo(b.changedDateTime!.day));

    return activityHistory;
  }

  Future<void> updateHistoryStatus(
    String id,
    String status,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference objectsRef = FirebaseDatabase.instance
        .ref()
        .child('usuarios')
        .child(currentUser!.uid)
        .child('history')
        .child("year-${DateTime.now().year.toString()}")
        .child("month-${DateTime.now().month.toString()}")
        .child("day-${DateTime.now().day.toString()}")
        .child(id);
    await objectsRef.set(HistoryItemModel(
            activityId: id, changedDateTime: DateTime.now(), newStatus: status)
        .toJson());
  }
}
