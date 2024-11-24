import 'package:flutter/material.dart';

class TranslatedTextWidget extends StatelessWidget {
  final String translatedText;

  const TranslatedTextWidget({super.key, required this.translatedText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        translatedText.isNotEmpty ? translatedText : 'Sin traducción disponible.',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
