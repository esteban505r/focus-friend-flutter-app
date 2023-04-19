import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/activity_model.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';
import 'package:focus_friend/ui/widgets/confirm_dialog.dart';
import 'package:focus_friend/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../model/leisure_activity_model.dart';
import '../../provider/streams/activityStreamProvider.dart';
import '../../provider/streams/leisureActivitiesStreamProvider.dart';
import '../widgets/fade_scale_widget.dart';


class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final activityStream = ref.watch(activityStreamProvider);
    return activityStream.when(
        data: (data) => SafeArea(
              child: _createBody(data),
            ),
        error: (error, stacktrace) {
          debugPrint(error.toString());
          return const Center(child: Text("ERROR"));
        },
        loading: () => const Center(
              child: CircularProgressIndicator(),
            ));
  }

  Widget _createBody(ActivityModel data) {
    final leisureStream = ref.watch(leisureActivitiesStreamProvider);
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: data.status != "pending"
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          Padding(
            padding: data.status != "pending"
                ? EdgeInsets.symmetric(vertical: 20)
                : EdgeInsets.zero,
            child: _createCard(data),
          ),
          if (data.status != "pending") ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                "Tienes tiempo libre, aqui hay algunos hobbies para ti",
                style: GoogleFonts.nunito(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
            leisureStream.when(
                data: (dataLeisure) => _createLeisureCard(data, dataLeisure),
                error: (error, stacktrace) {
                  debugPrint(error.toString());
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink())
          ],
          _createOptions(data)
        ],
      ),
    );
  }

  Widget _createCard(ActivityModel data) {
    return Stack(
      children: [
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('h:mm a').format(parseTimeString(data.time!)),
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff7C7C7C),
                  ),
                ),
                Visibility(
                  visible: data.status == "pending",
                  maintainAnimation: true,
                  maintainState: true,
                  child: AnimatedOpacity(
                    opacity: data.status != "pending" ? 0 : 1,
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Image.network(
                        data.image ?? '',
                        height: 200,
                        errorBuilder: (_, ___, __) {
                          return Image.asset(
                            "assets/placeholder.png",
                            height: 200,
                          );
                        },
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    data.name ?? '',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 23,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff222222),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        getStatus(data.status).isEmpty
            ? const SizedBox.shrink()
            : Positioned(
                top: 25,
                right: 5,
                child: AnimatedOpacity(
                  opacity: data.status != "pending" ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: FadeScaleWidget(
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 500),
                    child: Transform.rotate(
                      angle: 0.5,
                      child: InkWell(
                        onTap: () {
                          if (data.status != "pending") {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ConfirmDialog(
                                    message:
                                        "Quieres deshacer esta tarea completada?",
                                    title: "Deshacer tarea completada",
                                    onConfirm: () {
                                      ActivityRepository()
                                          .updateStatus(data.time!, "pending");
                                    },
                                  );
                                });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: getStatusColor(data.status),
                          ),
                          child: Text(
                            getStatus(data.status),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _createOptions(ActivityModel data) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: data.status != "pending" ? 0 : 1,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: data.status != "pending"
            ? const SizedBox.shrink()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ConfirmDialog(
                                    title: "Tarea completada",
                                    message:
                                        "Estas seguro de que completaste esta tarea?",
                                    onConfirm: () {
                                      ActivityRepository().updateStatus(
                                          data.time!, "completed");
                                    },
                                  );
                                });
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.greenAccent.shade100),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(100)))),
                          child: Image.asset(
                            'assets/happy.png',
                            height: 70,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ConfirmDialog(
                                    title: "Omitir tarea",
                                    message:
                                        "Estas seguro de que quieres omitir esta tarea?",
                                    onConfirm: () {
                                      ActivityRepository()
                                          .updateStatus(data.time!, "omitted");
                                    },
                                  );
                                });
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.amber.shade200),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(100)))),
                          child: Image.asset(
                            'assets/crying.png',
                            height: 70,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _createLeisureCard(
      ActivityModel data, List<LeisureActivityModel> leisureActivities) {
    return CarouselSlider.builder(
        itemCount: leisureActivities.length,
        itemBuilder: (context, index, index2) {
          LeisureActivityModel item = leisureActivities[index];
          return AnimatedOpacity(
            opacity: data.status != "pending" ? 1 : 0,
            duration: Duration(milliseconds: 500),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      item.image ?? '',
                      height: 200,
                      errorBuilder: (_, ___, __) {
                        return Image.asset(
                          "assets/placeholder.png",
                          height: 200,
                        );
                      },
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 15.0, left: 20, right: 20),
                      child: Text(
                        item.name ?? '',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 23,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff222222),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        options: CarouselOptions(height: 330));
  }
}
