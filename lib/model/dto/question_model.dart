class QuestionModel {
  Answers? answers;
  String? question;
  int? id;

  QuestionModel({this.answers, this.question, this.id});

  QuestionModel.fromJson(Map<String, dynamic> json,int this.id) {
    answers =
        json['answers'] != null ? Answers.fromJson(json['answers']) : null;
    question = json['question'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (answers != null) {
      data['answers'] = answers!.toJson();
    }
    data['question'] = question;
    return data;
  }
}

class Answers {
  String? first;
  String? fourth;
  String? second;
  String? third;

  Answers({this.first, this.fourth, this.second, this.third});

  Answers.fromJson(Map<dynamic, dynamic> json) {
    first = json['first'];
    fourth = json['fourth'];
    second = json['second'];
    third = json['third'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first'] = first;
    data['fourth'] = fourth;
    data['second'] = second;
    data['third'] = third;
    return data;
  }
}
