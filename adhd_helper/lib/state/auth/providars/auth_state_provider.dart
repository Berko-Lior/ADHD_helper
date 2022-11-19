import 'package:hashpro/state/auth/models/auth_state.dart';
import 'package:hashpro/state/auth/noyifiers/auth_state_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (_) => AuthStateNotifier(),
);
