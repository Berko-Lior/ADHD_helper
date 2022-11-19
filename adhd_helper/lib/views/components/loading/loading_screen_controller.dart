import 'package:flutter/foundation.dart' show immutable;

typedef CloseLoadinfScreen = bool Function();
typedef UpdateLoadinfScreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final CloseLoadinfScreen close;
  final UpdateLoadinfScreen update;

  const LoadingScreenController({
    required this.close,
    required this.update,
  });
}
