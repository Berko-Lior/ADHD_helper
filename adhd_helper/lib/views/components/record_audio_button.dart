import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hashpro/state/providers/audio_pruvider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordAidioButton extends ConsumerStatefulWidget {
  const RecordAidioButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RecordAidioButtonState();
}

class _RecordAidioButtonState extends ConsumerState<RecordAidioButton> {
  final recorder = FlutterSoundRecorder();
  var audioPlayer = audio.AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isRecorderReady = false;
  File? audioFile;

  Future record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: 'audio');
    audioFile = null;
    duration = Duration.zero;
    position = Duration.zero;
  }

  Future stop() async {
    if (!isRecorderReady) return;

    final path = await recorder.stopRecorder();

    if (path != null) {
      audioPlayer.setSourceDeviceFile(path);

      setState(() {
        audioFile = File(path);
        ref.read(audioProvider).setFile(audioFile);
      });
    }
  }

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

    await recorder.openRecorder();

    isRecorderReady = true;
    recorder.setSubscriptionDuration(const Duration(microseconds: 500));
  }

  @override
  void dispose() {
    recorder.closeRecorder();
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
                if (recorder.isRecording) {
                  await stop();
                } else {
                  await record();
                }

                setState(() {});
              },
              child: Icon(
                recorder.isRecording ? Icons.stop : Icons.mic,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();

                if (result != null) {
                  setState(() {
                    audioFile = File(result.files.single.path!);
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
      ],
    );
  }
}
