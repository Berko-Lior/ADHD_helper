import 'package:flutter/material.dart';
import 'package:hashpro/views/components/animations/models/lottie_animation.dart';
import 'package:lottie/lottie.dart';

class LottiAnimationView extends StatelessWidget {
  final LottieAnimation animation;
  final bool repeat;
  final bool reverse;

  const LottiAnimationView({
    super.key,
    required this.animation,
    this.repeat = true,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) => LottieBuilder.asset(
        animation.fullPath,
        repeat: repeat,
        reverse: reverse,
      );
}

extension GetFullPath on LottieAnimation {
  String get fullPath => 'assets/animations/$name.json';
}
