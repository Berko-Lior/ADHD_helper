import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hashpro/state/constatants/firebase_field_names.dart';
import 'package:hashpro/views/update_task/update_task_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TaskListTile extends StatelessWidget {
  final String deviceId;
  const TaskListTile({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref(deviceId).onValue,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData &&
            !snapshot.hasError &&
            snapshot.data.snapshot.value != null) {
          final String taskName =
              snapshot.data.snapshot.value[FirebaseFieldName.taskName];
          final int progress =
              snapshot.data.snapshot.value[FirebaseFieldName.progress];
          final int goal = snapshot.data.snapshot.value[FirebaseFieldName.goal];
          final int timeForTask =
              snapshot.data.snapshot.value[FirebaseFieldName.timeForTask];

          return GestureDetector(
            onLongPress: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => UpdateTaskScreen(
                  taskName: taskName,
                  goal: goal,
                  progress: progress,
                  deviceId: deviceId,
                  timeForGoal: timeForTask,
                ),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    taskName,
                    style: const TextStyle(fontSize: 20),
                  ),
                  subtitle: Text(
                    'Daily goal: $goal\nTime for task: $timeForTask',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                LinearPercentIndicator(
                    lineHeight: 25.0,
                    percent: progress <= goal ? progress / goal : 1,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                    center: Text(
                        '${((progress <= goal ? progress / goal : 1) * 100).toStringAsFixed(0)}%')),
              ],
            ),
          );
        } else {
          return const Text('');
        }
      },
    );
  }
}
