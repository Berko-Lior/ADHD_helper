import 'package:hashpro/views/components/animations/lotti_animation_view.dart';
import 'package:hashpro/views/components/animations/models/lottie_animation.dart';

class SmallErrorAnimationView extends LottiAnimationView {
  const SmallErrorAnimationView({super.key})
      : super(
          animation: LottieAnimation.smallError,
        );
}
