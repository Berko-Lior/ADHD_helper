import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:hashpro/state/constatants/firebase_collection_name.dart';
import 'package:hashpro/state/constatants/firebase_field_names.dart';
import 'package:hashpro/state/posts/typedefs/user_id.dart';
import 'package:hashpro/state/user_info/models/user_info_payload.dart';

@immutable
class UserInfoStorage {
  const UserInfoStorage();

  Future<bool> saveUserInfo({
    required UserId userId,
    required String displayName,
    required String? email,
  }) async {
    try {
      // First check if we have this user's info already.
      final userInfo = await FirebaseFirestore.instance
          .collection(
            FirebaseCollectionName.users,
          )
          .where(
            FirebaseFieldName.userId,
            isEqualTo: userId,
          )
          .limit(1)
          .get();
      if (userInfo.docs.isNotEmpty) {
        // We already have this user's info, so we want to update it.
        await userInfo.docs.first.reference.update({
          FirebaseFieldName.displayName: displayName,
          FirebaseFieldName.email: email ?? '',
        });
      } else {
        //We don't have this user's info, so we want to create a new user.
        final payload = UserInfoPatload(
          userId: userId,
          displayName: displayName,
          email: email,
        );
        await FirebaseFirestore.instance
            .collection(
              FirebaseCollectionName.users,
            )
            .add(
              payload,
            );
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
