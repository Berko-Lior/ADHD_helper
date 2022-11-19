import 'package:hashpro/state/comments/notifiers/delete_comment_notifier.dart';
import 'package:hashpro/state/image_upload/typedefs/is_loading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final deleteCommentProvider =
    StateNotifierProvider<DeleteCommentNotifier, IsLoading>(
  (_) => DeleteCommentNotifier(),
);
