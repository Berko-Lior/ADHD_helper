// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:hashpro/state/auth/providars/user_id_provider.dart';
// import 'package:hashpro/state/constatants/firebase_collection_name.dart';
// import 'package:hashpro/state/constatants/firebase_field_names.dart';
// import 'package:hashpro/state/post_settings/moders/post.dart';
// import 'package:hashpro/state/posts/models/post_key.dart';
// import 'package:hashpro/state/providers/user_devices_provider.dart';
// import 'package:hashpro/state/tasks/models/task_model.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// /// Provaid the post that the current user uploaded in the past.
// final userTasksProvider =
//     StreamProvider.family.autoDispose<Iterable<TaskModel>, List<String>>(
//   (ref, List<String> userDevises) {
//     final userId = ref.watch(userIdProvider);
//     final controller = StreamController<Iterable<TaskModel>>();

//     controller.onListen = () {
//       controller.sink.add([]);
//     };

//     var tasks = [];

//     for (var deviceId in userDevises) {
//       DatabaseReference deviceRef = FirebaseDatabase.instance.ref(deviceId);
//       deviceRef.onValue.listen((DatabaseEvent event) {
//         final data = event.snapshot.value as Map;
//         final task = TaskModel(
//           deviceId: deviceId,
//           goal: data[FirebaseFieldName.goal],
//           progress: data[FirebaseFieldName.progress],
//           taskName: data[FirebaseFieldName.taskName],
//         );
//         tasks.add(task);
//       });
//     }

//     final subscription = FirebaseFirestore.instance
//         .collection(FirebaseCollectionName.users)
//         .orderBy(FirebaseFieldName.createdAt, descending: true)
//         .where(PostKey.userId, isEqualTo: userId)
//         .snapshots()
//         .listen((snapshot) {
//       final docs = snapshot.docs;
//       final posts = docs
//           .where(
//             (doc) => !doc.metadata.hasPendingWrites,
//           )
//           .map(
//             (doc) => Post(
//               postId: doc.id,
//               json: doc.data(),
//             ),
//           );
//       controller.sink.add(posts);
//     });

//     ref.onDispose(() {
//       subscription.cancel();
//       controller.close();
//     });

//     return controller.stream;
//   },
// );
