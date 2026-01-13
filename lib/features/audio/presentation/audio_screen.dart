import 'dart:async';

import 'package:audio_project/features/audio/presentation/widget/input_bar_widget.dart';
import 'package:audio_project/features/audio/presentation/widget/message_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  final TextEditingController textController = TextEditingController();

  List<Map<String, dynamic>> messages = [];

  bool isRecording = false;
  bool isLocked = false;
  String? currentlyPlayingPath;

  StreamSubscription<Amplitude>? amplitudeSubscription;
  List<double> recordedWaves = [];
  Duration recordDuration = Duration.zero;
  Timer? timer;

  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    audioPlayer.positionStream.listen((p) {
      if (mounted) setState(() => currentPosition = p);
    });
    audioPlayer.durationStream.listen((d) {
      if (mounted) setState(() => totalDuration = d ?? Duration.zero);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    amplitudeSubscription?.cancel();
    audioRecorder.dispose();
    audioPlayer.dispose();
    textController.dispose();
    super.dispose();
  }


  Future<void> startRecording() async {
    if (!await audioRecorder.hasPermission()) return;

    final dir = await getApplicationDocumentsDirectory();
    final path =
        p.join(dir.path, "v_${DateTime.now().millisecondsSinceEpoch}.m4a");

    await audioRecorder.start(const RecordConfig(), path: path);

    setState(() {
      isRecording = true;
      isLocked = false;
      recordedWaves.clear();
      recordDuration = Duration.zero;
    });

    amplitudeSubscription = audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((amp) {
      setState(() {
        recordedWaves.add((amp.current + 60).clamp(5, 40));
      });
    });

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => recordDuration += const Duration(seconds: 1));
    });
  }

  Future<void> stopAndSendRecording() async {
    if (!isRecording) return;

    timer?.cancel();
    amplitudeSubscription?.cancel();

    final path = await audioRecorder.stop();
    if (path == null) return;

    setState(() {
      messages.insert(0, {
        "type": "audio",
        "path": path,
        "waves": List<double>.from(recordedWaves),
      });
      isRecording = false;
      isLocked = false;
    });
  }

  Future<void> cancelRecording() async {
    if (!isRecording) return;
    timer?.cancel();
    amplitudeSubscription?.cancel();
    await audioRecorder.stop();

    setState(() {
      isRecording = false;
      isLocked = false;
      recordedWaves.clear();
    });
  }

  void sendText() {
    if (textController.text.trim().isEmpty) return;
    setState(() {
      messages.insert(0, {
        "type": "text",
        "text": textController.text.trim(),
      });
      textController.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Chat AI",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(
              messages: messages,
              audioPlayer: audioPlayer,
              currentlyPlayingPath: currentlyPlayingPath,
              currentPosition: currentPosition,
              totalDuration: totalDuration,
              onPlay: (path) async {
                if (currentlyPlayingPath == path) {
                  audioPlayer.playing
                      ? await audioPlayer.pause()
                      : await audioPlayer.play();
                } else {
                  await audioPlayer.setFilePath(path);
                  setState(() => currentlyPlayingPath = path);
                  audioPlayer.play();
                }
              },
            ),
          ),
          InputBar(
            controller: textController,
            isRecording: isRecording,
            isLocked: isLocked,
            recordDuration: recordDuration,
            onStartRecord: startRecording,
            onCancel: cancelRecording,
            onStop: stopAndSendRecording,
            onSendText: sendText,
          ),
        ],
      ),
    );
  }
}
