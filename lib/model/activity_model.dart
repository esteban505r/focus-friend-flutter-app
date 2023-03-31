class ActivityModel {
  String? extraText;
  String? name;
  String? time;
  String? description;
  String? image;


  ActivityModel(
      {this.extraText, this.name, this.time, this.description, this.image});

  ActivityModel.fromJson(Map<String, dynamic> json) {
    extraText = json['extraText'];
    name = json['name'];
    time = json['time'];
    description = json['description'];
    image = json['image'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['extraText'] = extraText;
    data['name'] = name;
    data['time'] = time;
    data['description']=description;
    data['image']=image;
    return data;
  }
}