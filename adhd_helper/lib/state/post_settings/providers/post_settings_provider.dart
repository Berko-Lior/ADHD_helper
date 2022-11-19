import 'package:hashpro/state/post_settings/moders/post_setting.dart';
import 'package:hashpro/state/post_settings/notifiers/post_settings_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final postSettingProvider =
    StateNotifierProvider<PostSettingsNotifier, Map<PostSetting, bool>>(
  (ref) => PostSettingsNotifier(),
);
