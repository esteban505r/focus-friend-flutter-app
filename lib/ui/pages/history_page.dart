import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/controllers/history_controller.dart';
import 'package:focus_friend/model/calendar_history_cell_style.dart';
import 'package:focus_friend/model/dto/activity_model.dart';
import 'package:focus_friend/model/dto/history_day_item.dart';
import 'package:focus_friend/state/provider/future/historyItemProvider.dart';
import 'package:focus_friend/state/provider/future/historyItemsProvider.dart';
import 'package:focus_friend/task_status.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

    return activitiesStream.when(
        data: (activities) {
          if (activities.isNotEmpty) {
            return SafeArea(
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
                    child: ListView(
                      children: [
                        _createActivityHistory(
                            context, ref, state, controller, activities),
                        _createGeneralHistory(context, activities, ref, state)
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Text(
              "No tienes historial",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          );
        },
        error: (_, __) => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()));
  }

  Widget _createActivityHistory(
      BuildContext context,
      WidgetRef ref,
      HistoryState state,
      HistoryController controller,
      List<ActivityModel> activities) {
    final historyFuture = ref.watch(historyFutureProvider(state.activityId));
    return historyFuture.when(
        data: (data) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Por actividad",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 20, right: 20),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 0.0),
                      labelText: 'Actividad',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<String>(
                            isExpanded: true,
                            isDense: true,
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
                                      child: Text(
                                        '${activities[index].name ?? ''} (${activities[index].time})',
                                        overflow: TextOverflow.ellipsis,
                                      )))
                            ],
                            onChanged: (value) {
                              controller.setActivityId(value ?? '');
                            }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SfCalendar(
                    view: CalendarView.month,
                    initialDisplayDate: DateTime(state.year, state.month),
                    monthCellBuilder: (context, details) {
                      CalendarHistoryCellStyle style =
                          getCalendarCellStyleByHistoryItemList(
                                  date: details.date,
                                  history: data,
                                  backgroundColor: Colors.green,
                                  status: TaskStatus.COMPLETED.toString()) ??
                              getCalendarCellStyleByHistoryItemList(
                                  date: details.date,
                                  history: data,
                                  backgroundColor: Colors.amber,
                                  status: TaskStatus.OMITTED.toString()) ??
                              CalendarHistoryCellStyle(
                                  backgroundColor: Colors.transparent,
                                  borderRadius: null);
                      return Container(
                          decoration: BoxDecoration(
                              color: style.backgroundColor,
                              borderRadius: style.borderRadius,
                              border: Border.all(color: Colors.grey.shade300)),
                          child: Center(
                              child: Text(
                            details.date.day.toString(),
                            style: TextStyle(
                                color: details.date.month != state.month
                                    ? Colors.grey
                                    : Colors.black),
                          )));
                    },
                  ),
                ),
              ],
            ),
        error: (error, __) {
          print(error);
          return const SizedBox.shrink();
        },
        loading: () => const Center(child: CircularProgressIndicator()));
  }

  Widget _createGeneralHistory(BuildContext context,
      List<ActivityModel> activities, WidgetRef ref, HistoryState state) {
    final historyFuture =
        ref.watch(historyItemsFutureProvider(TaskStatus.COMPLETED));
    return historyFuture.when(
        data: (data) => Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 20.0, left: 20, bottom: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Por mes",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                        minimum: DateTime(state.year, state.month, 1),
                        maximum: DateTime(state.year, state.month, 31)),
                    primaryYAxis:
                        NumericAxis(maximum: activities.length.toDouble()),
                    series: <ChartSeries>[
                      LineSeries<HistoryDayItem?, DateTime>(
                          emptyPointSettings: EmptyPointSettings(
                              mode: EmptyPointMode.average, color: Colors.red),
                          dataSource: data,
                          xValueMapper: (HistoryDayItem? item, _) =>
                              item?.dateTime,
                          yValueMapper: (HistoryDayItem? item, _) =>
                              item?.historyList.length)
                    ]),
              ],
            ),
        error: (error, _) {
          print(error);
          return Text("ERROR");
        },
        loading: () => const SizedBox.shrink());
  }
}
