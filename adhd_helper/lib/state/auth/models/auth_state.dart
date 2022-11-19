import 'package:flutter/foundation.dart' show immutable;
import 'package:hashpro/state/auth/models/auth_resultd.dart';
import 'package:hashpro/state/posts/typedefs/user_id.dart';

@immutable
class AuthState {
  final AuthResult? result;
  final bool isloading;
  final UserId? userId;

  const AuthState({
    required this.result,
    required this.isloading,
    required this.userId,
  });

  const AuthState.logedOut()
      : result = null,
        isloading = false,
        userId = null;

  AuthState copiedWithIsLoading(bool isLoadingNewValu) => AuthState(
        result: result,
        isloading: isLoadingNewValu,
        userId: userId,
      );

  @override
  bool operator ==(covariant AuthState other) =>
      identical(this, other) ||
      (result == other.result &&
          isloading == other.isloading &&
          userId == other.userId);

  @override
  int get hashCode => Object.hash(
        result,
        isloading,
        userId,
      );
}
