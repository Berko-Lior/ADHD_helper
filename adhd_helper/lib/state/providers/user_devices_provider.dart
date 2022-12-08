import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hashpro/state/auth/providars/user_id_provider.dart';
import 'package:hashpro/state/constatants/firebase_collection_name.dart';
import 'package:hashpro/state/constatants/firebase_field_names.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userDevicesProvider = StreamProvider.autoDispose<List>((ref) {
  final controller = StreamController<List>();
  final userId = ref.watch(userIdProvider);

  final subscription = FirebaseFirestore.instance
      .collection(FirebaseCollectionName.users)
      .doc(userId)
      .collection(FirebaseCollectionName.devices)
      .snapshots()
      .listen(
    (snapshot) {
      final docs = snapshot.docs;
      final userDevices = [];
      for (var doc in docs) {
        userDevices.add(doc.data()[FirebaseFieldName.deviceId]);
      }
      controller.add(userDevices);
    },
  );

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});
