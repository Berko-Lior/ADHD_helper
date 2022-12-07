import 'dart:collection';
import 'package:flutter/foundation.dart' show immutable;
import 'package:hashpro/state/constatants/firebase_field_names.dart';

@immutable
class TaskModel extends MapView {
  final String taskName;
  final String deviceId;
  final int timeForTask;
  final int goal;
  final int progress;

  TaskModel({
    required this.timeForTask,
    required this.deviceId,
    required this.goal,
    required this.progress,
    required this.taskName,
  }) : super({
          FirebaseFieldName.timeForNextReset: timeForTask,
          FirebaseFieldName.timeForTask: timeForTask,
          FirebaseFieldName.deviceId: deviceId,
          FirebaseFieldName.goal: goal,
          FirebaseFieldName.progress: progress,
          FirebaseFieldName.taskName: taskName,
        });

  TaskModel.fromJson(
    Map<String, dynamic> json, {
    required String deviceId,
  }) : this(
          timeForTask: json[FirebaseFieldName.timeForNextReset],
          deviceId: deviceId,
          progress: json[FirebaseFieldName.progress],
          goal: json[FirebaseFieldName.goal],
          taskName: json[FirebaseFieldName.taskName],
        );
}
