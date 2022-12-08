import 'package:flutter/foundation.dart' show immutable;

@immutable
class FirebaseFieldName {
  static const userId = 'uid';
  static const timeForTask = 'time_for_task';
  static const timeForNextReset = 'time_for_next_reset';
  static const postId = 'post_id';
  static const comment = 'comment';
  static const createdAt = 'created_at';
  static const data = 'date';
  static const displayName = 'display_name';
  static const email = 'email';
  static const taskName = 'task_name';
  static const deviceId = 'device_id';
  static const goal = 'goal';
  static const progress = 'progress';
  static const pervProgress = 'prev_progress';
  static const timestemps = 'timestemps';
  static const devices = 'devices';
  static const audioFile = 'audio_file';
  const FirebaseFieldName._();
}
