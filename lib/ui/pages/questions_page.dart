import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/dto/question_model.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';
import 'package:focus_friend/state/provider/future/first_time_provider.dart';
import 'package:focus_friend/ui/pages/base_page.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionsPage extends ConsumerWidget {
  QuestionsPage({super.key});

  final pageController = PageController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<QuestionModel>> value = ref.watch(questionsProvider);
    return value.when(
        data: (value) {
          if (value.isEmpty) {
            Future.microtask(() {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainPage()));
            });
            return Container();
          }
          return Scaffold(
            body: PageView.builder(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: value.length,
                itemBuilder: (context, index) {
                  QuestionModel model = value[index];
                  return Column(
                    children: [
                      Expanded(
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: Theme.of(context).colorScheme.primary,
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              model.question ?? '',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  fontSize: 28, color: Colors.white),
                            ),
                          )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index2) {
                            return Card(
                              child: InkWell(
                                  radius: 8,
                                  onTap: () async {
                                    pageController.animateToPage(
                                        ((pageController.page ?? 0) + 1)
                                            .toInt(),
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.easeInOut);
                                    if (pageController.page == 9) {
                                      await ActivityRepository()
                                          .updateLastTimeAsked();
                                      await ActivityRepository()
                                          .updateLastQuestionsMultipleAsked(
                                          (((model.id ?? 0) + 1)/10).round()
                                      );
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const MainPage()));
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                shape: BoxShape.circle),
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          getAnswerByIndex(
                                                  model.answers, index2) ??
                                              'Sin respuesta',
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary),
                                        ),
                                      ),
                                    ],
                                  )),
                            );
                          },
                          itemCount: 4,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                        ),
                      )
                    ],
                  );
                }),
          );
        },
        error: (error, _) {
          return const Text("Error");
        },
        loading: () => const CircularProgressIndicator());
  }

  String? getAnswerByIndex(Answers? answers, int index) {
    Map map = <int, String?>{
      0: answers?.first,
      1: answers?.second,
      2: answers?.third,
      3: answers?.fourth
    };
    return map[index];
  }
}
