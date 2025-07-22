import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bible_reader_state.dart';
import '../bloc/bible_reader_bloc.dart';
import '../bloc/bible_reader_event.dart';
import '../../domain/entities/verse.dart';

class VerseListWidget extends StatelessWidget {
  final ScrollController scrollController;
  final BibleReaderLoaded state;

  const VerseListWidget({
    super.key,
    required this.scrollController,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Implement swipe gestures for chapter navigation
        if (details.primaryVelocity! > 500) {
          // Swipe right - previous chapter
          context.read<BibleReaderBloc>().add(const NavigateToPreviousChapter());
        } else if (details.primaryVelocity! < -500) {
          // Swipe left - next chapter  
          context.read<BibleReaderBloc>().add(const NavigateToNextChapter());
        }
      },
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20), // 20px horizontal padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16), // 8pt grid spacing
            
            // Book Title - H1
            Text(
              state.currentBook.nameLocal, // Use localized name
              style: const TextStyle(
                fontSize: 24, // 24px
                height: 32 / 24, // 32px line height
                fontWeight: FontWeight.w600, // SemiBold
              ),
            ),
            
            const SizedBox(height: 8), // 8pt grid spacing
            
            // Chapter Title - H2
            Text(
              'Chapter ${state.currentChapter}', // TODO: Localize
              style: TextStyle(
                fontSize: 18, // 18px
                height: 26 / 18, // 26px line height
                fontWeight: FontWeight.w500, // Medium
                color: Colors.grey[600], // Muted
              ),
            ),
            
            const SizedBox(height: 24), // 8pt grid spacing
            
            // Verse List
            ...state.verses.map((verse) => _buildVerseRow(context, verse)),
            
            const SizedBox(height: 100), // Bottom padding for gesture area
          ],
        ),
      ),
    );
  }

  Widget _buildVerseRow(BuildContext context, Verse verse) {
    final isHighlighted = state.highlights.any(
      (h) => h.bookId == verse.bookId && 
             h.chapterNumber == verse.chapterNumber && 
             h.verseNumber == verse.verseNumber,
    );
    
    final highlight = isHighlighted 
        ? state.highlights.firstWhere(
            (h) => h.bookId == verse.bookId && 
                   h.chapterNumber == verse.chapterNumber && 
                   h.verseNumber == verse.verseNumber,
          )
        : null;

    return GestureDetector(
      onLongPress: () => _showVerseActionSheet(context, verse),
      onDoubleTap: () => _showVerseActionSheet(context, verse),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8), // 8pt grid spacing
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: isHighlighted
            ? BoxDecoration(
                color: Color(int.parse(highlight!.color.replaceFirst('#', '0xFF'))),
                borderRadius: BorderRadius.circular(4),
              )
            : null,
        child: RichText(
          text: TextSpan(
            children: [
              // Verse Number - superscript, muted
              TextSpan(
                text: '${verse.verseNumber} ',
                style: TextStyle(
                  fontSize: 12, // 12px
                  height: 16 / 12, // 16px line height
                  fontWeight: FontWeight.w500, // Medium
                  color: const Color(0xFF9AA0A6), // #9AA0A6 (light/muted)
                ),
              ),
              // Verse Text - body
              TextSpan(
                text: verse.text,
                style: const TextStyle(
                  fontSize: 18, // 18px
                  height: 28 / 18, // 28px line height
                  fontWeight: FontWeight.w400, // Regular
                  color: Colors.black, // Will be adjusted by theme
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVerseActionSheet(BuildContext context, Verse verse) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _VerseActionSheet(verse: verse),
    );
  }
}

class _VerseActionSheet extends StatelessWidget {
  final Verse verse;

  const _VerseActionSheet({required this.verse});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button at top right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${verse.bookId} ${verse.chapterNumber}:${verse.verseNumber}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionButton(
                icon: Icons.highlight,
                label: 'Highlight',
                onTap: () {
                  Navigator.of(context).pop();
                  _showColorPicker(context);
                },
              ),
              _ActionButton(
                icon: Icons.bookmark,
                label: 'Save in Marker',
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement marker functionality
                },
              ),
              _ActionButton(
                icon: Icons.note_add,
                label: 'Add Note',
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddNoteDialog(context);
                },
              ),
              _ActionButton(
                icon: Icons.copy,
                label: 'Copy Text',
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement copy functionality
                },
              ),
              _ActionButton(
                icon: Icons.share,
                label: 'Share Text',
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement share functionality
                },
              ),
              _ActionButton(
                icon: Icons.image,
                label: 'Share as Image',
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement share as image functionality
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    // TODO: Implement color picker for highlights
  }

  void _showAddNoteDialog(BuildContext context) {
    // TODO: Implement add note dialog
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
