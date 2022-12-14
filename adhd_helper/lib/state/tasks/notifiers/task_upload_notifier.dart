import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hashpro/state/constatants/firebase_collection_name.dart';
import 'package:hashpro/state/constatants/firebase_field_names.dart';
import 'package:hashpro/state/posts/typedefs/user_id.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TaskUploadNotifier extends StateNotifier<bool> {
  TaskUploadNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> uploadTask({
    required String deviceId,
    required String taskName,
    required int goal,
    required int timeForGoal,
    int progross = 0,
    File? audioFile,
    required UserId userId,
  }) async {
    isLoading = true;
    try {
      // Check if device exist
      final storageRef = FirebaseStorage.instance.ref().child(deviceId);
      final ref = FirebaseDatabase.instance.ref(deviceId);
      final snapshot = await ref.get();
      if (!snapshot.exists) {
        return false;
      }

      // Check if the device is initializad
      final deviceOwnerId = await ref.child(FirebaseFieldName.userId).get();
      if (deviceOwnerId.exists) {
        if (deviceOwnerId.value != userId) {
          isLoading = false;
          return false;
        } else {
          if (audioFile != null) {
            await storageRef.putFile(audioFile);
          }
          // update task
          await ref.update({
            FirebaseFieldName.taskName: taskName,
            FirebaseFieldName.goal: goal,
            FirebaseFieldName.progress: progross,
            FirebaseFieldName.pervProgress: progross,
            FirebaseFieldName.timeForNextReset: timeForGoal,
            FirebaseFieldName.timeForTask: timeForGoal,
          });
        }
      } else {
        if (audioFile != null) {
          await storageRef.putFile(audioFile);
        }
        // connect the device to the user
        FirebaseFirestore.instance
            .collection(FirebaseCollectionName.users)
            .doc(userId)
            .collection(FirebaseCollectionName.devices)
            .doc(deviceId)
            .set(
          {
            FirebaseFieldName.deviceId: deviceId,
          },
        );

        // Create new task.
        await ref.set({
          FirebaseFieldName.pervProgress: progross,
          FirebaseFieldName.userId: userId,
          FirebaseFieldName.taskName: taskName,
          FirebaseFieldName.goal: goal,
          FirebaseFieldName.progress: progross,
          FirebaseFieldName.timeForNextReset: timeForGoal,
          FirebaseFieldName.timeForTask: timeForGoal,
          FirebaseFieldName.timestemps: {},
        });
      }
    } catch (_) {
      isLoading = false;
      return false;
    }

    isLoading = false;
    return true;
  }
}
