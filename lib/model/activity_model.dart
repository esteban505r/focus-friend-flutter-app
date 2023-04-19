class ActivityModel {
  String? id;
  String? extraText;
  String? name;
  String? time;
  String? description;
  String? status;
  String? image;
  String? lastUpdate;
  String? endingTime;

  ActivityModel({
    this.id,
    this.extraText,
    this.name,
    this.time,
    this.description,
    this.image,
    this.status,
    this.lastUpdate,
    this.endingTime,
  });

  ActivityModel.fromJson(String this.id, Map<String, dynamic> json) {
    extraText = json['extraText'];
    name = json['name'];
    time = json['time'];
    description = json['description'];
    image = json['image'];
    status = json['status'];
    lastUpdate = json['last_update'];

    try {
      DateTime date = DateTime.parse(lastUpdate ?? '');
      if (date.day < DateTime
          .now()
          .day || date.month < DateTime
          .now()
          .month) {
        status = 'pending';
      }
    } catch (e) {
      print(e);
    }

    if (json['ending_time'] != null) {
      endingTime = json['ending_time'];
    } else {
      endingTime = null;
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['extraText'] = extraText;
      data['name'] = name;
      data['time'] = time;
      data['description'] = description;
      data['image'] = image;
      data['status'] = status;
      data['last_update'] = lastUpdate;
      data['ending_time'] = endingTime;
      return data;
    }
  }


}