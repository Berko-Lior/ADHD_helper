import 'package:flutter/material.dart';
import 'package:hashpro/state/image_upload/models/thumbnail_request.dart';
import 'package:hashpro/state/image_upload/providers/thumbnail_provider.dart';
import 'package:hashpro/views/components/animations/loading_animation_view.dart';
import 'package:hashpro/views/components/animations/small_error_animation_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FileThumbnailView extends ConsumerWidget {
  final ThumbnailRequest thumbnailRequest;
  const FileThumbnailView({
    required this.thumbnailRequest,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnail = ref.watch(thumbnailProvider(thumbnailRequest));
    return thumbnail.when(
      data: (imageWithAspectRatio) => AspectRatio(
        aspectRatio: imageWithAspectRatio.aspectRatio,
        child: imageWithAspectRatio.image,
      ),
      loading: () => const LoadingAnimationView(),
      error: (error, stackTrace) => const SmallErrorAnimationView(),
    );
  }
}
