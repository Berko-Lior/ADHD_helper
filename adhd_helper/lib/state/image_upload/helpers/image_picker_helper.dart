import 'dart:io';

import 'package:flutter/foundation.dart' show immutable;
import 'package:hashpro/state/image_upload/extentions/to_file.dart';
import 'package:image_picker/image_picker.dart';

@immutable
class ImagePickerHerper {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<File?> pickImageFromGallert() =>
      _imagePicker.pickImage(source: ImageSource.gallery).toFile();

  static Future<File?> pickVideoFromGallert() =>
      _imagePicker.pickVideo(source: ImageSource.gallery).toFile();
}
