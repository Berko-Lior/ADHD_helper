import 'package:flutter/material.dart';
import 'package:hashpro/state/auth/providars/auth_state_provider.dart';
import 'package:hashpro/views/components/dialogs/alert_dialog_model.dart';
import 'package:hashpro/views/components/dialogs/logout_dialog.dart';
import 'package:hashpro/views/constants/strings.dart';
import 'package:hashpro/views/tasks/tasks_screan.dart';
import 'package:hashpro/views/update_task/update_task_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.appName),
          actions: [
            IconButton(
              onPressed: () async {
                final shouldLogOut =
                    await const LogoutDialog().present(context).then(
                          (value) => value ?? false,
                        );
                if (shouldLogOut) {
                  await ref.read(authStateProvider.notifier).logOut();
                }
              },
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.person),
              ),
              Tab(
                icon: Icon(Icons.person),
              ),
              Tab(
                icon: Icon(Icons.person),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const TasksScreen(),
            Container(),
            Container(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const UpdateTaskScreen(),
            ),
          ),
          child: const Icon(
            Icons.add,
          ),
        ),
      ),
    );
  }
}
