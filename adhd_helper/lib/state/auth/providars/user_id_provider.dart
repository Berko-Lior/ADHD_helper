import 'package:hashpro/state/auth/providars/auth_state_provider.dart';
import 'package:hashpro/state/posts/typedefs/user_id.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userIdProvider = Provider<UserId?>(
  (ref) => ref.watch(authStateProvider).userId,
);
