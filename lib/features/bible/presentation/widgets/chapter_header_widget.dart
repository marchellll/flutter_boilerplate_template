import 'package:flutter/material.dart';
import '../models/bible_reader_models.dart';

class ChapterHeaderWidget extends StatelessWidget {
  final BibleReaderState state;

  const ChapterHeaderWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with action buttons
          Row(
            children: [
              // Book title + Chapter number
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: state.currentBookLocal,
                        style: TextStyle(
                          fontSize: 28,
                          height: 36 / 28,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      TextSpan(
                        text: ' ${state.currentChapter}',
                        style: const TextStyle(
                          fontSize: 28,
                          height: 36 / 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Action buttons (right aligned)
              Row(
                children: [
                  // Play Audio Button (hidden when not at top)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: state.isTopBarVisible ? 1.0 : 0.0,
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Audio playback coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.play_circle_outline),
                      iconSize: 28,
                    ),
                  ),
                  // Display Settings Icon (hidden when not at top)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: state.isTopBarVisible ? 1.0 : 0.0,
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Display settings coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.text_fields),
                      iconSize: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
