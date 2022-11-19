import 'package:hashpro/state/auth/providars/auth_state_provider.dart';
import 'package:hashpro/state/image_upload/providers/image_upload_provider.dart';
import 'package:hashpro/state/tasks/providers/task_upload_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  final isUploadingImage = ref.watch(imageUploadNofifierProvider);
  final isUploadinfTask = ref.watch(taskUploadProvider);

  return authState.isloading || isUploadingImage || isUploadinfTask;
});
