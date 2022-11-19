import 'package:flutter/material.dart';
import 'package:hashpro/state/providers/user_devices_provider.dart';
import 'package:hashpro/views/components/animations/empty_contents_with_text_animation_view.dart';
import 'package:hashpro/views/components/animations/error_animation_view.dart';
import 'package:hashpro/views/components/animations/loading_animation_view.dart';
import 'package:hashpro/views/constants/strings.dart';
import 'package:hashpro/views/tasks_list_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TasksScreen extends StatefulHookConsumerWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(userDevicesProvider);
    return RefreshIndicator(
      onRefresh: () {
        ref.refresh(userDevicesProvider);

        // Even if sometime it will refresh instantly, we want to show the
        //refresh indicator for 1 second so the user will know that the refresh hepened.
        return Future.delayed(const Duration(seconds: 1));
      },
      child: devices.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const EmptyContentsWithTextAnimationView(
                text: Strings.youHaveNoTasks);
          } else {
            return TasksListView(
              tasks: tasks,
            );
          }
        },
        error: (error, stackTrace) => const ErrorAnimationView(),
        loading: () => const LoadingAnimationView(),
      ),
    );
  }
}
