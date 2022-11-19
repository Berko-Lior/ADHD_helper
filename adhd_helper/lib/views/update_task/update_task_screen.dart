import 'package:flutter/material.dart';
import 'package:hashpro/state/auth/providars/user_id_provider.dart';
import 'package:hashpro/state/posts/typedefs/user_id.dart';
import 'package:hashpro/state/tasks/providers/task_upload_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UpdateTaskScreen extends ConsumerWidget {
  final String? deviceId;
  final String? taskName;
  final int? goal;
  final int? progress;
  const UpdateTaskScreen({
    this.taskName,
    this.goal,
    this.progress,
    super.key,
    this.deviceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceIdController = TextEditingController(text: deviceId);
    final taskNameController = TextEditingController(text: taskName);
    final goalController = TextEditingController(text: goal?.toString() ?? '');
    final UserId userId = ref.watch(userIdProvider)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ListView(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Device ID:'),
              controller: deviceIdController,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: 'Task name:'),
              controller: taskNameController,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: 'Goal: '),
              controller: goalController,
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () async {
                int? goal = int.tryParse(goalController.text.trim());
                if (taskNameController.text.isEmpty ||
                    deviceIdController.text.isEmpty ||
                    goal == null) {
                  // TODO: show dialog
                } else {
                  final res =
                      await ref.read(taskUploadProvider.notifier).uploadTask(
                            deviceId: deviceIdController.text,
                            taskName: taskNameController.text,
                            goal: goal,
                            userId: userId,
                          );
                  if (!res) {
                    // TODO: show dialog
                    print('not my');
                  } else {
                    Navigator.of(context).pop();
                  }
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.pink.withOpacity(0.7),
                foregroundColor: Colors.yellow,
              ),
              child: const Text('Add task'),
            ),
          ],
        ),
      ),
    );
  }
}
