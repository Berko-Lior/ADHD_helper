import 'package:flutter/material.dart';
import 'package:hashpro/views/task_tile.dart';

class TasksListView extends StatelessWidget {
  final List tasks;
  const TasksListView({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: TaskTile(
            deviceId: tasks[index],
          ),
        );
      },
    );
  }
}
