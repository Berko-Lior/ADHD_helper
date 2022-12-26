import 'package:flutter/material.dart';
import 'package:hashpro/state/auth/providars/auth_state_provider.dart';
import 'package:hashpro/views/components/dialogs/alert_dialog_model.dart';
import 'package:hashpro/views/components/dialogs/logout_dialog.dart';
import 'package:hashpro/views/constants/strings.dart';
import 'package:hashpro/views/data_graph_view.dart';
import 'package:hashpro/views/tasks/tasks_screan.dart';
import 'package:hashpro/views/update_task/update_task_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(
                  Icons.bookmark, // alternative ballot_outlined
                  size: 36,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.assessment_outlined, // alternative bar_chart_sharp
                  size: 36,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            TasksScreen(),
            DataGraphView(),
          ],
        ),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => const UpdateTaskScreen(),
                  ),
                ),
                child: const Icon(
                  Icons.add,
                ),
              )
            : null,
      ),
    );
  }
}
