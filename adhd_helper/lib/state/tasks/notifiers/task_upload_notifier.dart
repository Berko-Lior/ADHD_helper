import 'package:firebase_database/firebase_database.dart';
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
    int progross = 0,
    required UserId userId,
  }) async {
    isLoading = true;
    try {
      // Check if device exist
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
          // update task
          await ref.update({
            FirebaseFieldName.taskName: taskName,
            FirebaseFieldName.goal: goal,
            FirebaseFieldName.progress: progross,
          });
        }
      } else {
        // Create new task.
        await ref.set({
          FirebaseFieldName.userId: userId,
          FirebaseFieldName.taskName: taskName,
          FirebaseFieldName.goal: goal,
          FirebaseFieldName.progress: progross,
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
