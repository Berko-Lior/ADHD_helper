import 'package:hashpro/state/tasks/notifiers/task_upload_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final taskUploadProvider = StateNotifierProvider<TaskUploadNotifier, bool>(
  (ref) => TaskUploadNotifier(),
);
