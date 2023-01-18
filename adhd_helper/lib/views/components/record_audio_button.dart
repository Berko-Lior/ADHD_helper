import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hashpro/state/providers/audio_pruvider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';

class RecordAidioButton extends ConsumerStatefulWidget {
  const RecordAidioButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RecordAidioButtonState();
}

bool isMp3File(String? path) {
  if (path == null || path.length <= 3) return false;
  final pathLen = path.length;
  return path[pathLen - 1] == '3' &&
      path[pathLen - 2] == 'p' &&
      path[pathLen - 3] == 'm';
}

class _RecordAidioButtonState extends ConsumerState<RecordAidioButton> {
  // final recorder = FlutterSoundRecorder();
  var audioPlayer = audio.AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isRecorderReady = false;
  File? audioFile;
  bool isComplete = true;
  bool isMp3 = true;

  Future record() async {
    // if (!isRecorderReady) return;
    // await recorder.startRecorder(toFile: 'audio.mp4');
    final path = await getFilePath();
    RecordMp3.instance.start(path, (type) {
      Permission.microphone.request();
    });
    isComplete = false;
    audioFile = null;
    duration = Duration.zero;
    position = Duration.zero;
  }

  Future<String> getFilePath() async {
    final storageDirectory = await getTemporaryDirectory();
    String path = "${storageDirectory.path}/record";
    var d = Directory(path);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return "$path/audio.mp3";
  }

  Future stop() async {
    // if (!isRecorderReady) return;

    // final path = await recorder.stopRecorder();
    RecordMp3.instance.stop();
    final path = await getFilePath();
    isMp3 = true;

    if (path != null) {
      // String? mp3File = await mp4Tomp3(path);
      // if (mp3File == null) return;

      audioPlayer.setSourceDeviceFile(path);

      setState(() {
        isComplete = true;
        audioFile = File(path);
        ref.read(audioProvider).setFile(audioFile);
      });
    }
  }

  // Future<String?> mp4Tomp3(path) async {
  //   FFmpegSession session = await FFmpegKit.execute('-i $path my_audio.mp3');
  //   final returnCode = await session.getReturnCode();

  //   if (ReturnCode.isSuccess(returnCode)) {
  //     return 'my_audio.mp3';
  //   } else {
  //     return null;
  //   }
  // }

  @override
  void initState() {
    super.initState();

    audioPlayer.setReleaseMode(audio.ReleaseMode.stop);

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == audio.PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPsition) {
      setState(() {
        position = newPsition;
      });
    });

    initRecorder();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphon permission not granted';
    }

    // await recorder.openRecorder();

    // isRecorderReady = true;
    // recorder.setSubscriptionDuration(const Duration(microseconds: 500));
  }

  @override
  void dispose() {
    // recorder.closeRecorder();
    audioPlayer.dispose();

    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secondes = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 1) hours,
      minutes,
      secondes,
    ].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (!isComplete) {
                  await stop();
                } else {
                  await record();
                }

                setState(() {});
              },
              child: Icon(
                !isComplete ? Icons.stop : Icons.mic,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom, allowedExtensions: ['mp3']);

                if (result != null) {
                  setState(() {
                    isMp3 = isMp3File(result.paths.first);
                    audioFile = isMp3 ? File(result.files.single.path!) : null;
                    audioPlayer.setSourceDeviceFile(result.files.single.path!);
                    ref.read(audioProvider).setFile(audioFile);
                  });
                }
              },
              child: const Icon(Icons.file_upload),
            ),
          ],
        ),
        audioFile == null
            ? const Text('')
            : Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await audioPlayer.seek(position);
                },
              ),
        audioFile == null
            ? const Text('')
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatTime(position)),
                  Text(formatTime(duration - position)),
                ],
              ),
        audioFile == null
            ? const Text('')
            : CircleAvatar(
                radius: 30,
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  iconSize: 40,
                  onPressed: () async {
                    if (isPlaying) {
                      await audioPlayer.pause();
                    } else if (audioFile != null) {
                      await audioPlayer.resume();
                    }
                  },
                ),
              ),
        isMp3
            ? const Text('')
            : const Text(
                'Audio mast be of mp3 format, pleas upload another audio file.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
      ],
    );
  }
}
