import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

class InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isRecording;
  final bool isLocked;
  final Duration recordDuration;
  final VoidCallback onStartRecord;
  final VoidCallback onStop;
  final VoidCallback onCancel;
  final VoidCallback onSendText;

  const InputBar({
    super.key,
    required this.controller,
    required this.isRecording,
    required this.isLocked,
    required this.recordDuration,
    required this.onStartRecord,
    required this.onStop,
    required this.onCancel,
    required this.onSendText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onLongPress: onStartRecord,
                        onLongPressEnd: (_) {
                          if (isRecording && !isLocked) onStop();
                        },
                        onLongPressMoveUpdate: (details) {
                          if (!isRecording || isLocked) return;

                          if (details.localPosition.dx > 80) onCancel();
                        },
                        child: Icon(
                          isRecording ? Icons.mic : Icons.mic_none,
                          color: isRecording ? Colors.red : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: isRecording
                            ? Row(
                                children: [
                                  Text(
                                    _format(recordDuration),
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey,
                                      highlightColor: Colors.grey.shade400,
                                      period: const Duration(seconds: 3),
                                      child: Text(
                                        "Slide Up 🔒 or Right ❌",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  hintText: "Write your query",
                                  border: InputBorder.none,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                if (isRecording && !isLocked)
                  Positioned(
                    top: -70,
                    left: 5,
                    child: Column(
                      children: [
                        // Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                        Lottie.asset(
                          "assets/animations/locked_animation.json",

                          width: 50,
                          height: 50,
                        ),

                        const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),
          GestureDetector(
            onTap: isRecording ? onStop : onSendText,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.green.shade800,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _format(Duration d) =>
      "${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
}
