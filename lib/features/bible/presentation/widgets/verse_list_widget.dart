import 'package:flutter/material.dart';
import '../models/bible_reader_models.dart';
import 'chapter_header_widget.dart';
import 'verse_widget.dart';
import 'verse_action_sheet.dart';

class VerseListWidget extends StatelessWidget {
  final BibleReaderState state;
  final ScrollController scrollController;

  const VerseListWidget({
    super.key,
    required this.state,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  // Book title + Chapter number with audio and settings buttons
                  return ChapterHeaderWidget(state: state);
                } else {
                  // Verses
                  final verseIndex = index - 1;
                  if (verseIndex >= state.verses.length) return null;

                  final verse = state.verses[verseIndex];
                  return VerseWidget(
                    verse: verse,
                    onLongPress: () => VerseActionSheet.show(context, verse),
                  );
                }
              },
              childCount: state.verses.length + 1,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}
