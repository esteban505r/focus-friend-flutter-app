class ActivityModel {
  String? extraText;
  String? name;
  String? time;
  String? description;
  String? status;
  String? image;
  String? lastUpdate;

  ActivityModel({
    this.extraText,
    this.name,
    this.time,
    this.description,
    this.image,
    this.status,
    this.lastUpdate,
  });

  ActivityModel.fromJson(Map<String, dynamic> json) {
    extraText = json['extraText'];
    name = json['name'];
    time = json['time'];
    description = json['description'];
    image = json['image'];
    status = json['status'];
    lastUpdate = json['last_update'];
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
