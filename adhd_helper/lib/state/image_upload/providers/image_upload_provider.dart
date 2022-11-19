import 'package:hashpro/state/image_upload/notifiers/image_upload_notifier.dart';
import 'package:hashpro/state/image_upload/typedefs/is_loading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final imageUploadNofifierProvider =
    StateNotifierProvider<ImageUploadNotifier, IsLoading>(
  (ref) => ImageUploadNotifier(),
);
