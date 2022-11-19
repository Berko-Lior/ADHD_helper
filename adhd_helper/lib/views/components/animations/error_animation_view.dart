import 'package:hashpro/views/components/animations/lotti_animation_view.dart';
import 'package:hashpro/views/components/animations/models/lottie_animation.dart';

class ErrorAnimationView extends LottiAnimationView {
  const ErrorAnimationView({super.key})
      : super(
          animation: LottieAnimation.error,
        );
}
