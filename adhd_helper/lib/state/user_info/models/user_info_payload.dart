import 'dart:collection' show MapView;
import 'package:flutter/foundation.dart' show immutable;
import 'package:hashpro/state/constatants/firebase_field_names.dart';
import 'package:hashpro/state/posts/typedefs/user_id.dart';

@immutable
class UserInfoPatload extends MapView<String, dynamic> {
  UserInfoPatload({
    required UserId userId,
    required String? displayName,
    required String? email,
    List<dynamic> devices = const [],
  }) : super(
          {
            FirebaseFieldName.userId: userId,
            FirebaseFieldName.displayName: displayName ?? '',
            FirebaseFieldName.email: email ?? '',
            FirebaseFieldName.devices: devices,
          },
        );
}

var gui = {};
