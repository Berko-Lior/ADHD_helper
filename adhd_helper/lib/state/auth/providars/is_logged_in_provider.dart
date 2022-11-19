import 'package:hashpro/state/auth/models/auth_resultd.dart';
import 'package:hashpro/state/auth/providars/auth_state_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final isLoggedInProvider = Provider<bool>(
  (ref) {
    final authState = ref.watch(authStateProvider);
    return authState.result == AuthResult.success;
  },
);
