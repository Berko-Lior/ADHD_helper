import 'package:flutter/material.dart';
import 'package:hashpro/state/auth/providars/user_id_provider.dart';
import 'package:hashpro/state/posts/typedefs/user_id.dart';
import 'package:hashpro/state/providers/audio_pruvider.dart';
import 'package:hashpro/state/tasks/providers/task_upload_provider.dart';
import 'package:hashpro/views/components/record_audio_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UpdateTaskScreen extends ConsumerWidget {
  final String? deviceId;
  final String? taskName;
  final int? timeForGoal;
  final int? goal;
  final int? progress;
  const UpdateTaskScreen({
    this.timeForGoal,
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
    final timeForGoalController =
        TextEditingController(text: timeForGoal?.toString() ?? '');
    final UserId userId = ref.watch(userIdProvider)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/modify new task'),
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
            const SizedBox(height: 20),
            TextField(
              decoration:
                  const InputDecoration(labelText: 'Time for goal(days): '),
              controller: timeForGoalController,
            ),
            const SizedBox(height: 20),
            const RecordAidioButton(),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () async {
                int? goal = int.tryParse(goalController.text.trim());
                int? timeForGoal =
                    int.tryParse(timeForGoalController.text.trim());
                if (taskNameController.text.isEmpty ||
                    deviceIdController.text.isEmpty ||
                    goal == null ||
                    timeForGoal == null) {
                  // TODO: show dialog
                } else {
                  final audioFile = ref.read(audioProvider).audioFile;
                  final res =
                      await ref.read(taskUploadProvider.notifier).uploadTask(
                            deviceId: deviceIdController.text,
                            taskName: taskNameController.text,
                            goal: goal,
                            userId: userId,
                            audioFile: audioFile,
                            timeForGoal: timeForGoal,
                          );
                  if (!res) {
                    // TODO: show dialog
                  } else {
                    Navigator.of(context).pop();
                  }
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update task'),
            ),
          ],
        ),
      ),
    );
  }
}
