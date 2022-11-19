import 'dart:collection';
import 'package:flutter/foundation.dart' show immutable;
import 'package:hashpro/state/constatants/firebase_field_names.dart';

@immutable
class TaskModel extends MapView {
  final String taskName;
  final String deviceId;
  final int goal;
  final int progress;

  TaskModel({
    required this.deviceId,
    required this.goal,
    required this.progress,
    required this.taskName,
  }) : super({
          FirebaseFieldName.deviceId: deviceId,
          FirebaseFieldName.goal: goal,
          FirebaseFieldName.progress: progress,
          FirebaseFieldName.taskName: taskName,
        });

  TaskModel.fromJson(
    Map<String, dynamic> json, {
    required String deviceId,
  }) : this(
          deviceId: deviceId,
          progress: json[FirebaseFieldName.progress],
          goal: json[FirebaseFieldName.goal],
          taskName: json[FirebaseFieldName.taskName],
        );
}
