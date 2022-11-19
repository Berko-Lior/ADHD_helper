import 'package:hashpro/views/components/animations/lotti_animation_view.dart';
import 'package:hashpro/views/components/animations/models/lottie_animation.dart';

class DataNotFoundAnimationView extends LottiAnimationView {
  const DataNotFoundAnimationView({super.key})
      : super(
          animation: LottieAnimation.dataNotFound,
        );
}
