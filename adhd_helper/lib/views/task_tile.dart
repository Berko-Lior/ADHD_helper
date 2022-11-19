import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hashpro/state/constatants/firebase_field_names.dart';

class TaskTile extends StatefulWidget {
  final String deviceId;
  const TaskTile({super.key, required this.deviceId});

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  String? taskName;
  int? goal;
  int? progress;
  StreamSubscription<DatabaseEvent>? taskNameSream;
  StreamSubscription<DatabaseEvent>? goalSream;
  StreamSubscription<DatabaseEvent>? progresseSream;

  @override
  void dispose() {
    taskNameSream?.cancel();
    goalSream?.cancel();
    progresseSream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference taskNameRef = FirebaseDatabase.instance
        .ref('${widget.deviceId}/${FirebaseFieldName.taskName}');
    taskNameSream = taskNameRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      setState(() {
        print(data);
        taskName = data as String;
      });
    });

    DatabaseReference goalRef = FirebaseDatabase.instance
        .ref('${widget.deviceId}/${FirebaseFieldName.goal}');
    goalRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      setState(() {
        print(data);
        goal = data as int;
      });
    });

    DatabaseReference progressRef = FirebaseDatabase.instance
        .ref('${widget.deviceId}/${FirebaseFieldName.progress}');
    progressRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      setState(() {
        print(data);
        progress = data as int;
      });
    });

    return Container(
      child: taskName == null || goal == null
          ? const Text('null')
          : Text('$taskName  $goal $progress'),
    );
  }
}
