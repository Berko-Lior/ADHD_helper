import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hashpro/state/auth/providars/user_id_provider.dart';
import 'package:hashpro/state/constatants/firebase_collection_name.dart';
import 'package:hashpro/state/constatants/firebase_field_names.dart';
import 'package:hashpro/state/post_settings/moders/post.dart';
import 'package:hashpro/state/posts/models/post_key.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provaid the post that the current user uploaded in the past.
final userPostsProvider = StreamProvider.autoDispose<Iterable<Post>>(
  (ref) {
    final userId = ref.watch(userIdProvider);
    final controller = StreamController<Iterable<Post>>();

    controller.onListen = () {
      controller.sink.add([]);
    };

    final subscription = FirebaseFirestore.instance
        .collection(FirebaseCollectionName.posts)
        .orderBy(FirebaseFieldName.createdAt, descending: true)
        .where(PostKey.userId, isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final docs = snapshot.docs;
      final posts = docs
          .where(
            (doc) => !doc.metadata.hasPendingWrites,
          )
          .map(
            (doc) => Post(
              postId: doc.id,
              json: doc.data(),
            ),
          );
      controller.sink.add(posts);
    });

    ref.onDispose(() {
      subscription.cancel();
      controller.close();
    });

    return controller.stream;
  },
);
