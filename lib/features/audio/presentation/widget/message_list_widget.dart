import 'package:audio_project/features/audio/presentation/widget/audio_bubble_widget.dart';
import 'package:audio_project/features/audio/presentation/widget/text_bubble_widget.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MessageList extends StatelessWidget {
  final List messages;
  final AudioPlayer audioPlayer;
  final String? currentlyPlayingPath;
  final Duration currentPosition;
  final Duration totalDuration;
  final Function(String) onPlay;

  const MessageList({
    super.key,
    required this.messages,
    required this.audioPlayer,
    required this.currentlyPlayingPath,
    required this.currentPosition,
    required this.totalDuration,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(15),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[i];
        return msg["type"] == "audio"
            ? AudioBubble(
                path: msg["path"],
                waves: msg["waves"],
                isPlaying: currentlyPlayingPath == msg["path"],
                currentPosition: currentPosition,
                totalDuration: totalDuration,
                audioPlayer: audioPlayer,
                onTap: () => onPlay(msg["path"]),
              )
            : TextBubble(text: msg["text"]);
      },
    );
  }
}
