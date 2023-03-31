import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/model/activity_model.dart';
import 'package:focus_friend/ui/widgets/confirm_dialog.dart';
import 'package:focus_friend/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../provider/streams/activityStreamProvider.dart';
import '../ui/widgets/fade_scale_widget.dart';

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
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('h:mm a')
                            .format(parseTimeString(data.time!)),
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff7C7C7C),
                        ),
                      ),
                      Padding(
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
              getStatus(data.status).isEmpty ? SizedBox.shrink() : Positioned(
                top: 25,
                right: 5,
                child: AnimatedOpacity(
                  opacity: data.status!="pending" ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: FadeScaleWidget(
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 500),
                    child: Transform.rotate(
                      angle: 0.5,
                      child: InkWell(
                        onTap: () {
                          if (data.status!="pending") {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ConfirmDialog(
                                    message:
                                        "Quieres deshacer esta tarea completada?",
                                    title: "Deshacer tarea completada",
                                    onConfirm: (){
                                      ref
                                          .read(
                                          activityRepositoryProvider)
                                          .updateStatus(
                                          data.time!, "pending");
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
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
              opacity: data.status!="pending" ? 0 : 1,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: data.status!="pending"
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 20),
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
                                            ref
                                                .read(
                                                    activityRepositoryProvider)
                                                .updateStatus(
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
                                            ref
                                                .read(
                                                activityRepositoryProvider)
                                                .updateStatus(
                                                data.time!, "omitted");
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
          )
        ],
      ),
    );
  }

  String getStatus(String? status) {
    switch(status){
      case "completed":
        return "Completado";
      case "omitted":
        return "Omitido";
      default:
        return '';
    }
  }

  Color getStatusColor(String? status) {
    switch(status){
      case "completed":
        return Colors.green;
      case "omitted":
        return Colors.amber;
      default:
        return Colors.green;
    }
  }
}
