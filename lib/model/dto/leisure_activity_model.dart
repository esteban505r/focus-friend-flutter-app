class LeisureActivityModel {
  int? leisureLevel;
  String? name;
  String? image;
  String? description;

  LeisureActivityModel({
    this.leisureLevel,
    this.name,
    this.image,
    this.description,
  });

  LeisureActivityModel.fromJson(Map<String, dynamic> json) {
    leisureLevel = json['leisureLevel'];
    name = json['name'];
    image = json['image'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['leisureLevel'] = leisureLevel;
    data['name'] = name;
    data['image'] = image;
    data['description'] = description;
    return data;
  }
}
