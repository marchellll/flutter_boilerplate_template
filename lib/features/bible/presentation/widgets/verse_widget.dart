import 'package:flutter/material.dart';
import '../models/bible_reader_models.dart';

class VerseWidget extends StatelessWidget {
  final VerseData verse;
  final VoidCallback onLongPress;

  const VerseWidget({
    super.key,
    required this.verse,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: verse.isHighlighted
                ? Color(int.parse(verse.highlightColor!.replaceFirst('#', '0xFF')))
                : null,
            borderRadius: verse.isHighlighted ? BorderRadius.circular(2) : null,
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${verse.number} ',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500,
                    color: verse.isHighlighted
                        ? const Color(0xFF757575) // Darker gray for highlighted verses
                        : const Color(0xFF9AA0A6),
                  ),
                ),
                TextSpan(
                  text: verse.text,
                  style: TextStyle(
                    fontSize: 18,
                    height: 28 / 18,
                    fontWeight: FontWeight.w400,
                    color: verse.isHighlighted
                        ? const Color(0xFF212121) // Dark color for highlighted text
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (verse.hasNote)
                  const TextSpan(
                    text: ' 📝',
                    style: TextStyle(fontSize: 14),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
