import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hashpro/state/constatants/firebase_field_names.dart';
import 'package:hashpro/state/providers/user_devices_provider.dart';
import 'package:hashpro/views/components/animations/empty_contents_with_text_animation_view.dart';
import 'package:hashpro/views/components/animations/error_animation_view.dart';
import 'package:hashpro/views/components/animations/loading_animation_view.dart';
import 'package:hashpro/views/constants/strings.dart';
import 'package:hashpro/views/line_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class Pair<T> {
  final DateTime a;
  final T b;

  bool operator <=(Pair other) {
    return a.isBefore(other.a);
  }

  int commperTo(Pair other) {
    return a.difference(other.a).inDays;
  }

  Pair(this.a, this.b);
}

class DataGraphView extends ConsumerStatefulWidget {
  const DataGraphView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DataGraphViewState();
}

class _DataGraphViewState extends ConsumerState<DataGraphView> {
  List<DateTime?> rangeDatePickerValue = [
    DateTime.now().subtract(const Duration(days: 7)),
    DateTime.now()
  ];

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(userDevicesProvider);

    return devices.when(
      data: (data) => ListView.builder(
        itemCount: devices.value?.length,
        itemBuilder: (BuildContext context, int index) {
          if (data.isEmpty) {
            return const EmptyContentsWithTextAnimationView(
                text: Strings.youHaveNoTasks);
          } else {
            return FutureBuilder(
              future: FirebaseDatabase.instance.ref(data[index]).get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LoadingAnimationView();
                } else {
                  final Iterable<Pair<Object?>> datesData = snapshot.data!
                      .child(FirebaseFieldName.timestemps)
                      .children
                      .map((e) => Pair(
                          DateFormat("EEE MMM dd yyyy").parse(e.key!),
                          (e.value)));
                  List<Pair<Object?>> relevantDatesData = datesData
                      .where((element) =>
                          element.a.isAfter(rangeDatePickerValue.first!) &&
                          element.a.isBefore(rangeDatePickerValue.last!))
                      .toList();

                  relevantDatesData.sort((a, b) => a.commperTo(b));

                  late final Iterable<FlSpot> graphDots;
                  late final DateTime startingDate;
                  if (relevantDatesData.isEmpty) {
                    graphDots = [];
                    startingDate = DateTime.now();
                  } else {
                    Pair firstDay = relevantDatesData.first;
                    startingDate = firstDay.a;
                    for (Pair currData in relevantDatesData) {
                      if (currData <= firstDay) {
                        firstDay = currData;
                      }
                    }

                    graphDots = relevantDatesData.map(
                      (e) => FlSpot(
                          e.a.difference(firstDay.a).inDays.toDouble(),
                          double.parse(e.b.toString())),
                    );
                  }

                  return Column(
                    children: [
                      CalendarDatePicker2(
                        config: CalendarDatePicker2Config(
                          calendarType: CalendarDatePicker2Type.range,
                        ),
                        onValueChanged: (dates) {
                          if (dates.isNotEmpty) {
                            setState(() {
                              rangeDatePickerValue = dates;
                            });
                          }
                        },
                        initialValue: rangeDatePickerValue,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${snapshot.data!.child(FirebaseFieldName.taskName).value.toString()} Progress',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      LineChartWidget(
                        deviceId: data[index],
                        dots: graphDots.toList(),
                        startingDate: startingDate,
                      ),
                    ],
                  );
                }
              },
            );
          }
        },
      ),
      error: (error, stackTrace) => const ErrorAnimationView(),
      loading: () => const LoadingAnimationView(),
    );
  }
}
