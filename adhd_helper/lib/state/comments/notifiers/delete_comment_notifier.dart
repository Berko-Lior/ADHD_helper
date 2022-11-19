import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hashpro/state/comments/typedefs/comment_id.dart';
import 'package:hashpro/state/constatants/firebase_collection_name.dart';
import 'package:hashpro/state/image_upload/typedefs/is_loading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeleteCommentNotifier extends StateNotifier<IsLoading> {
  DeleteCommentNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> deleteComment({
    required CommentId commentId,
  }) async {
    isLoading = true;
    try {
      final query = FirebaseFirestore.instance
          .collection(FirebaseCollectionName.comments)
          .where(FieldPath.documentId, isEqualTo: commentId)
          .limit(1)
          .get();

      await query.then((value) async {
        for (final doc in value.docs) {
          await doc.reference.delete();
        }
      });

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
