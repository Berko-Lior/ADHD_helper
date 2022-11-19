import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hashpro/state/constatants/firebase_collection_name.dart';
import 'package:hashpro/state/image_upload/constants/image_upload_constants.dart';
import 'package:hashpro/state/image_upload/exceptions/could_not_builde_thumbnail_exception.dart';
import 'package:hashpro/state/image_upload/extentions/get_collectio_name_from_file_type.dart';
import 'package:hashpro/state/image_upload/extentions/get_data_image_aspect_ratio.dart';
import 'package:hashpro/state/posts/models/post_payload.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:hashpro/state/image_upload/models/file_type.dart';
import 'package:hashpro/state/image_upload/typedefs/is_loading.dart';
import 'package:hashpro/state/post_settings/moders/post_setting.dart';
import 'package:hashpro/state/posts/typedefs/user_id.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ImageUploadNotifier extends StateNotifier<IsLoading> {
  ImageUploadNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> upload({
    required File file,
    required FileType fileType,
    required String message,
    required Map<PostSetting, bool> postSettings,
    required UserId userId,
  }) async {
    isLoading = true;

    // Calculate the post thumbnail.
    late Uint8List thumbnailUint8List;

    switch (fileType) {
      case FileType.image:
        final fileAsImage = img.decodeImage(file.readAsBytesSync());
        if (fileAsImage == null) {
          isLoading = false;
          throw const CouldNotBuildThumbnailException();
        }
        final thumbnail = img.copyResize(fileAsImage,
            width: ImageUploadConstants.imageThumbnailWidth);
        final thumbnailData = img.encodeJpg(thumbnail);
        thumbnailUint8List = Uint8List.fromList(thumbnailData);
        break;

      case FileType.video:
        final thumbnail = await VideoThumbnail.thumbnailData(
          video: file.path,
          maxHeight: ImageUploadConstants.videoThumbnailMaxHeight,
          quality: ImageUploadConstants.videoThumbnailQuality,
        );
        if (thumbnail == null) {
          isLoading = false;
          throw const CouldNotBuildThumbnailException();
        } else {
          thumbnailUint8List = thumbnail;
        }
        break;
    }

    // Calculate the aspect ratio.
    final thumbnailAspectRatio = await thumbnailUint8List.getAspectRatio();

    // Calculate references.
    final fileName = const Uuid().v4();

    // Create references to the thumbnail and the image itself.
    final thumbnailRef = FirebaseStorage.instance
        .ref()
        .child(userId)
        .child(FirebaseCollectionName.thumbnails)
        .child(fileName);

    final originalFileRef = FirebaseStorage.instance
        .ref()
        .child(userId)
        .child(fileType.collectionName)
        .child(fileName);

    try {
      // Upload thumbnaill to firebase.
      final thmbnailUploadTask = await thumbnailRef.putData(thumbnailUint8List);
      final thumbnailStorageId = thmbnailUploadTask.ref.name;

      // Upload the original file to firebase.
      final originalFileUploadTask = await originalFileRef.putFile(file);
      final originalFileStorageId = originalFileUploadTask.ref.name;

      // Upload the post itself.
      final postPaload = PostPayload(
        userId: userId,
        message: message,
        thumbnailUrl: await thumbnailRef.getDownloadURL(),
        fileUrl: await originalFileRef.getDownloadURL(),
        fileType: fileType,
        fileName: fileName,
        aspectRatio: thumbnailAspectRatio,
        thumbnailStorageId: thumbnailStorageId,
        originalFileStorageId: originalFileStorageId,
        postSettings: postSettings,
      );
      await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.posts)
          .add(postPaload);

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
