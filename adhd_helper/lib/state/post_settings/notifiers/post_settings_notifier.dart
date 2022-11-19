import 'package:collection/collection.dart';
import 'package:hashpro/state/post_settings/moders/post_setting.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostSettingsNotifier extends StateNotifier<Map<PostSetting, bool>> {
  PostSettingsNotifier()
      : super(
          UnmodifiableMapView(
            {
              for (final setting in PostSetting.values) setting: true,
            },
          ),
        );

  void setSetting({
    required PostSetting setting,
    required bool value,
  }) {
    final existingValue = state[setting];
    if (existingValue != null && existingValue != value) {
      state = Map.unmodifiable(
        Map.from(state)..[setting] = value,
      );
    }
  }
}
