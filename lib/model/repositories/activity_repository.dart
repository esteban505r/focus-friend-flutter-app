import 'package:firebase_database/firebase_database.dart';
import 'package:focus_friend/model/activity_model.dart';
import 'package:focus_friend/utils.dart';

class ActivityRepository {

  Future<void> updateStatus(String hour, String status) async {
    DatabaseReference objectsRef = FirebaseDatabase.instance.ref().child("activities");
    Query query = objectsRef.orderByChild("time").equalTo(hour);

    var result = await query.once();
    if (result.snapshot.value != null) {
      Map<dynamic, dynamic> values = Map<dynamic,dynamic>.from(result.snapshot.value as Map<Object?,Object?>);
      String objectId = values.keys.first;
      objectsRef.child(objectId).update({"status": status});
    }
  }


  Stream<ActivityModel> getActivity() {
    DatabaseReference ref = FirebaseDatabase.instance.ref();

    return ref
        .child('activities')
        .onValue
        .map((event) {
      Map<dynamic, dynamic> values = event.snapshot.value as Map<dynamic, dynamic>;
      List<dynamic> filteredValues = values.values.where((activity) {
        DateTime activityTime = parseTimeString(activity['time']);
        DateTime now = DateTime.now();
        return activityTime.hour <= now.hour ||
            (activityTime.hour == now.hour && activityTime.minute <= now.minute);
      }).toList();

      if (filteredValues.isNotEmpty) {
        Map<Object?, Object?> latestActivity = filteredValues.reduce((curr, next) {
          DateTime currTime = parseTimeString(curr['time']);
          DateTime nextTime = parseTimeString(next['time']);

          return (currTime.isAfter(nextTime)) ? curr : next;
        });

        return ActivityModel.fromJson(Map<String,dynamic>.from(latestActivity));
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
            .add(ActivityModel.fromJson(Map<String, dynamic>.from(value)));
      });
      activities.sort((a, b) {
        DateTime dateA = parseTimeString(a.time!);
        DateTime dateB = parseTimeString(b.time!);
       return dateA.compareTo(dateB);
      });
      return activities;
    });
  }
}
