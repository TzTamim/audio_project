import 'package:flutter/material.dart';

class TextBubble extends StatelessWidget {
  final String text;
  const TextBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 50),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFFFFB2C1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(2),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
