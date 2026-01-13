import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioBubble extends StatelessWidget {
  final String path;
  final List<double> waves;
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final AudioPlayer audioPlayer;
  final VoidCallback onTap;

  const AudioBubble({
    super.key,
    required this.path,
    required this.waves,
    required this.isPlaying,
    required this.currentPosition,
    required this.totalDuration,
    required this.audioPlayer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    int skip = (waves.length / 30).ceil().clamp(1, 100);
    List<double> display = [];
    for (int i = 0; i < waves.length; i += skip) {
      display.add(waves[i]);
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15, left: 80),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 5),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onTap,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black,
                child: Icon(
                  isPlaying && audioPlayer.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Row(
              children: display.asMap().entries.map((e) {
                bool active =
                    isPlaying &&
                    totalDuration.inMilliseconds > 0 &&
                    (e.key / display.length <=
                        currentPosition.inMilliseconds /
                            totalDuration.inMilliseconds);
                return Container(
                  width: 3,
                  height: e.value * .7,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: active ? Colors.black : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
