import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/dto/question_model.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';

AutoDisposeFutureProvider<List<QuestionModel>> questionsProvider =
    FutureProvider.autoDispose<List<QuestionModel>>((ref) {
  return ActivityRepository().getQuestions();
});
