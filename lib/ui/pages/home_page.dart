import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_friend/model/dto/activity_model.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';
import 'package:focus_friend/ui/widgets/confirm_dialog.dart';
import 'package:focus_friend/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../model/dto/leisure_activity_model.dart';
import '../../state/provider/streams/activityStreamProvider.dart';
import '../../state/provider/streams/leisureActivitiesStreamProvider.dart';
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
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery
            .of(context)
            .size
            .height,
        child: activityStream.when(
            data: (data) {
              return SafeArea(
                child: _createBody(data),
              );
            },
            error: (error, stacktrace) {
              debugPrint(error.toString());
              return const Center(child: Text("ERROR"));
            },
            loading: () =>
            const Center(
              child: CircularProgressIndicator(),
            )),
      ),
    );
  }

  Widget _createBody(ActivityModel? data) {
    final leisureStream = ref.watch(leisureActivitiesStreamProvider);
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 30.0, top: 20),
                  child: IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.black45,
                      size: 30,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/focus_friend.svg",
                      height: 50,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Focus Friend",
                      style: GoogleFonts.alegreyaSans(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Builder(
              builder: (context) {
                if (data != null) {
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: _createCard(data),
                        ),
                        if (data.status != "pending") ...[
                          leisureStream.when(
                              data: (dataLeisure) =>
                                  Column(
                                    children: [

                                      if(dataLeisure.isNotEmpty)
                                        ...<Widget>[
                                          _createLeisureCard(data, dataLeisure),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 20.0),
                                            child: Text(
                                              "Tienes tiempo libre, aqui hay algunos hobbies para ti",
                                              style: GoogleFonts.nunito(
                                                  fontSize: 22),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      if(dataLeisure.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 20.0),
                                          child: Text(
                                            "Tienes tiempo libre!",
                                            style: GoogleFonts.nunito(
                                                fontSize: 22),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  ),
                              error: (error, stacktrace) {
                                debugPrint(error.toString());
                                return const SizedBox.shrink();
                              },
                              loading: () => const SizedBox.shrink())
                        ],
                        data.status == "pending"
                            ? _createOptions(data)
                            : const SizedBox.shrink()
                      ],
                    ),
                  );
                }
                return _createEmptyCard();
              }
          ),
        ],
      ),
    );
  }

  Widget _createEmptyCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          width: MediaQuery
              .of(context)
              .size
              .width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.watch_later,
                    color: Theme
                        .of(context)
                        .primaryColor,
                    size: 17,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    DateFormat('h:mm a')
                        .format(parseTimeString('00:00')),
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Image.asset(
                    "assets/placeholder.png",
                    height: 150,
                  )
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Aun no tienes actividades, crea una!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
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
  }

  Widget _createCard(ActivityModel data) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 8),
              child: Text(
                "Tarea actual",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    color: Colors.grey),
              ),
            ),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.watch_later,
                          color: Theme
                              .of(context)
                              .primaryColor,
                          size: 17,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          DateFormat('h:mm a')
                              .format(parseTimeString(data.time ?? '00:00')),
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
                            height: 150,
                            errorBuilder: (_, ___, __) {
                              return Image.asset(
                                "assets/placeholder.png",
                                height: 150,
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
                        style: GoogleFonts.roboto(
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
          ],
        ),
        getStatus(data.status).isEmpty
            ? const SizedBox.shrink()
            : Positioned(
          top: 55,
          right: 5,
          child: AnimatedOpacity(
            opacity: data.status != "pending" ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: FadeScaleWidget(
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 500),
              child: Transform.rotate(
                angle: 0.4,
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

  Widget _createOption(ActivityModel data,
      {required IconData icon,
        required bool isRight,
        required void Function() onPressed}) =>
      GestureDetector(
        onTap: onPressed,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
              elevation: MaterialStateProperty.resolveWith<double>((states) {
                if (states.contains(MaterialState.pressed)) {
                  return 2;
                }
                return 7;
              }),
              backgroundColor: !isRight
                  ? MaterialStateProperty.all(Colors.green)
                  : MaterialStateProperty.all(Colors.redAccent),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft:
                      isRight ? const Radius.circular(30) : Radius.zero,
                      topLeft:
                      isRight ? const Radius.circular(30) : Radius.zero,
                      topRight:
                      !isRight ? const Radius.circular(30) : Radius.zero,
                      bottomRight: !isRight
                          ? const Radius.circular(30)
                          : Radius.zero)))),
          child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(
                  left:
                  !isRight ? MediaQuery
                      .of(context)
                      .size
                      .width * 0.12 : 20,
                  right:
                  isRight ? MediaQuery
                      .of(context)
                      .size
                      .width * 0.12 : 20,
                  top: 20,
                  bottom: 20),
              child: Icon(icon)),
        ),
      );

  Widget _createOptions(ActivityModel data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _createOption(data, icon: Icons.check, isRight: false, onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return ConfirmDialog(
                    title: "Tarea completada",
                    message: "Estas seguro de que completaste esta tarea?",
                    onConfirm: () {
                      ActivityRepository()
                          .updateStatus(data.time!, "completed");
                    },
                  );
                });
          }),
          _createOption(data, icon: Icons.close, isRight: true, onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return ConfirmDialog(
                    title: "Omitir tarea",
                    message: "Estas seguro de que quieres omitir esta tarea?",
                    onConfirm: () {
                      ActivityRepository().updateStatus(data.time!, "omitted");
                    },
                  );
                });
          }),
        ],
      ),
    );
  }

  Widget _createLeisureCard(ActivityModel data,
      List<LeisureActivityModel> leisureActivities) {
    return CarouselSlider.builder(
        itemCount: leisureActivities.length,
        itemBuilder: (context, index, index2) {
          LeisureActivityModel item = leisureActivities[index];
          return AnimatedOpacity(
            opacity: data.status != "pending" ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.8,
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
