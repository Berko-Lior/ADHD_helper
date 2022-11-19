import 'package:flutter/material.dart';
import 'package:hashpro/state/image_upload/exceptions/could_not_builde_thumbnail_exception.dart';
import 'package:hashpro/state/image_upload/extentions/get_image_aspect_ratio.dart';
import 'package:hashpro/state/image_upload/models/file_type.dart';
import 'package:hashpro/state/image_upload/models/imag_with_asspect_ratio.dart';
import 'package:hashpro/state/image_upload/models/thumbnail_request.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// A provider that recive a ThumbnailRequest and return ImageWithAspectRatio.
final thumbnailProvider =
    FutureProvider.family.autoDispose<ImageWithAspectRatio, ThumbnailRequest>(
  (ref, ThumbnailRequest request) async {
    final Image image;

    switch (request.fileType) {
      case FileType.image:
        image = Image.file(
          request.file,
          fit: BoxFit.fitHeight,
        );
        break;

      case FileType.video:
        final thumb = await VideoThumbnail.thumbnailData(
          video: request.file.path,
          imageFormat: ImageFormat.JPEG,
          quality: 75,
        );
        if (thumb == null) {
          throw const CouldNotBuildThumbnailException();
        } else {
          image = Image.memory(
            thumb,
            fit: BoxFit.fitHeight,
          );
        }
        break;
    }
    final aspectRatio = await image.getAspectRatio();
    return ImageWithAspectRatio(
      image: image,
      aspectRatio: aspectRatio,
    );
  },
);
