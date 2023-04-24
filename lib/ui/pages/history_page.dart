import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/controllers/history_controller.dart';
import 'package:focus_friend/model/calendar_history_cell_style.dart';
import 'package:focus_friend/model/dto/activity_model.dart';
import 'package:focus_friend/model/dto/history_item_model.dart';
import 'package:focus_friend/state/provider/future/historyItemProvider.dart';
import 'package:focus_friend/task_status.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../state/provider/controllers/history_provider.dart';
import '../../state/provider/streams/activitiesStreamProvider.dart';
import '../../state/state/history_state.dart';
import '../../utils.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesStream = ref.watch(activitiesStreamProvider);
    HistoryState state = ref.watch(historyControllerNotifierProvider);
    HistoryController controller =
        ref.read(historyControllerNotifierProvider.notifier);
    final historyFuture = ref.watch(historyFutureProvider(state.activityId));

    return activitiesStream.when(
        data: (activities) => Scaffold(
                body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      "Historial",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 20),
                        child: DropdownButton<String>(
                            value: state.activityId,
                            menuMaxHeight: 300,
                            items: [
                              const DropdownMenuItem<String>(
                                  value: '',
                                  child: Text('Selecciona una actividad')),
                              ...List.generate(
                                  activities.length,
                                  (index) => DropdownMenuItem<String>(
                                      value: activities[index].id ?? '',
                                      child:
                                          Text(activities[index].name ?? '')))
                            ],
                            onChanged: (value) {
                              controller.setActivityId(value ?? '');
                            }),
                      ),
                      historyFuture.when(
                          data: (data) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SfCalendar(
                                  view: CalendarView.month,
                                  initialDisplayDate:
                                      DateTime(state.year, state.month),
                                  monthCellBuilder: (context, details) {
                                    CalendarHistoryCellStyle
                                        style = getCalendarCellStyleByHistoryItemList(
                                                date: details.date,
                                                history: data,
                                                backgroundColor: Colors.green,
                                                status: TaskStatus.COMPLETED
                                                    .toString()) ??
                                            getCalendarCellStyleByHistoryItemList(
                                                date: details.date,
                                                history: data,
                                                backgroundColor: Colors.amber,
                                                status: TaskStatus.OMITTED
                                                    .toString()) ??
                                            CalendarHistoryCellStyle(
                                                backgroundColor:
                                                    Colors.transparent,
                                                borderRadius: null);
                                    return Container(
                                        decoration: BoxDecoration(
                                            color: style.backgroundColor,
                                            borderRadius: style.borderRadius,
                                            border: Border.all(
                                                color: Colors.grey.shade300)),
                                        child: Center(
                                            child: Text(
                                          details.date.day.toString(),
                                          style: TextStyle(
                                              color: details.date.month !=
                                                      state.month
                                                  ? Colors.grey
                                                  : Colors.black),
                                        )));
                                  },
                                ),
                              ),
                          error: (_, __) => const SizedBox.shrink(),
                          loading: () => const CircularProgressIndicator())
                    ],
                  )),
                ],
              ),
            )),
        error: (_, __) => const SizedBox.shrink(),
        loading: () => const CircularProgressIndicator());
  }
}
