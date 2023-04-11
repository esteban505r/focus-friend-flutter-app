class ActivityModel {
  String? id;
  String? extraText;
  String? name;
  String? time;
  String? description;
  String? status;
  String? image;
  String? lastUpdate;

  ActivityModel({
    this.id,
    this.extraText,
    this.name,
    this.time,
    this.description,
    this.image,
    this.status,
    this.lastUpdate,
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
      if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        status = 'pending';
      }
    } catch (e) {
      print(e);
    }
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
    return data;
  }
}
