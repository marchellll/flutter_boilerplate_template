import 'package:flutter/material.dart';
import '../models/bible_reader_models.dart';

class FloatingPillWidget extends StatelessWidget {
  final BibleReaderState state;
  final VoidCallback onVersionTap;
  final VoidCallback onNavigationTap;

  const FloatingPillWidget({
    super.key,
    required this.state,
    required this.onVersionTap,
    required this.onNavigationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: state.isTopBarVisible ? 1.0 : 0.7,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Version button
            GestureDetector(
              onTap: onVersionTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
                  state.currentVersion,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Vertical separator
            Container(
              width: 1,
              height: 24,
              color: Colors.white.withValues(alpha: 0.3),
            ),

            // Chapter reference button
            GestureDetector(
              onTap: onNavigationTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
                  '${state.currentBookLocal} ${state.currentChapter}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
