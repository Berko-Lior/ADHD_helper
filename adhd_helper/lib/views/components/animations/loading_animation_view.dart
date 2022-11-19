import 'package:hashpro/views/components/animations/lotti_animation_view.dart';
import 'package:hashpro/views/components/animations/models/lottie_animation.dart';

class LoadingAnimationView extends LottiAnimationView {
  const LoadingAnimationView({super.key})
      : super(
          animation: LottieAnimation.loading,
        );
}
