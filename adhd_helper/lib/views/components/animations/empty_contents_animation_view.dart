import 'package:hashpro/views/components/animations/lotti_animation_view.dart';
import 'package:hashpro/views/components/animations/models/lottie_animation.dart';

class EmptyContentsAnimationView extends LottiAnimationView {
  const EmptyContentsAnimationView({super.key})
      : super(
          animation: LottieAnimation.empty,
        );
}
