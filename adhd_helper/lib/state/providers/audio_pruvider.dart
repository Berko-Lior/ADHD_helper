import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

final audioProvider = Provider<AudioFile>((_) => AudioFile());

class AudioFile {
  File? audioFile;

  AudioFile({this.audioFile});

  void setFile(File? newFile) {
    audioFile = newFile;
  }
}
