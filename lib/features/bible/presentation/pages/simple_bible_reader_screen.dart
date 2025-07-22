import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/simple_bible_bloc.dart';
import '../models/simple_models.dart';

class SimpleBibleReaderScreen extends StatefulWidget {
  const SimpleBibleReaderScreen({super.key});

  @override
  State<SimpleBibleReaderScreen> createState() => _SimpleBibleReaderScreenState();
}

class _SimpleBibleReaderScreenState extends State<SimpleBibleReaderScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<SimpleBibleBloc>().add(const LoadInitialData());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimpleBibleBloc, SimpleBibleState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                // Swipe gestures for chapter navigation
                if (details.velocity.pixelsPerSecond.dx > 500) {
                  // Swipe right - previous chapter
                  context.read<SimpleBibleBloc>().add(const NavigateToPreviousChapter());
                } else if (details.velocity.pixelsPerSecond.dx < -500) {
                  // Swipe left - next chapter
                  context.read<SimpleBibleBloc>().add(const NavigateToNextChapter());
                }
              },
              child: Stack(
                children: [
                  // Main content - verses
                  Positioned.fill(
                    child: _buildVerseList(state),
                  ),
                  
                  // Menu Bar (Auto-hide) - No top bar as per guidelines
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: state.isMenuBarVisible ? 0 : -80,
                    left: 0,
                    right: 0,
                    child: _buildMenuBar(),
                  ),
                  
                  // Floating Verse Pill FAB
                  Positioned(
                    bottom: state.isMenuBarVisible ? 100 : 20,
                    right: 20,
                    child: _buildFloatingPill(state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerseList(SimpleBibleState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  // Book title + Chapter number in one line
                  return Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: state.currentBookLocal,
                            style: TextStyle(
                              fontSize: 28,
                              height: 36 / 28, 
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme color
                            ),
                          ),
                          TextSpan(
                            text: ' ${state.currentChapter}',
                            style: TextStyle(
                              fontSize: 28,
                              height: 36 / 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.red, // Red accent color for chapter number
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // Verses (removed the separate chapter title since it's now combined)
                  final verseIndex = index - 1; // Adjusted index since we removed one title
                  if (verseIndex >= state.verses.length) return null;
                  
                  final verse = state.verses[verseIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onLongPress: () {
                        _showVerseActionSheet(verse);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: verse.isHighlighted 
                              ? Color(int.parse(verse.highlightColor!.replaceFirst('#', '0xFF')))
                              : null,
                          borderRadius: verse.isHighlighted ? BorderRadius.circular(2) : null,
                        ),
                        padding: verse.isHighlighted ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2) : null,
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
              },
              childCount: state.verses.length + 1, // Updated count since we combined titles
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildMenuBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor, // 100% opacity as requested
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMenuButton(Icons.home, 'Home', () {}),
          _buildMenuButton(Icons.book, 'Bible', () {}),
          _buildMenuButton(Icons.calendar_today, 'Plans', () {}),
          _buildMenuButton(Icons.search, 'Search', () {}),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingPill(SimpleBibleState state) {
    return GestureDetector(
      onTap: () {
        // TODO: Open navigation modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigation modal coming soon!')),
        );
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: state.isTopBarVisible ? 1.0 : 0.7,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '${state.currentVersion} | ${state.currentBookLocal} ${state.currentChapter}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _showVerseActionSheet(VerseData verse) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ayat ${verse.number}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton('Highlight', Icons.highlight, () {}),
                _buildActionButton('Bookmark', Icons.bookmark, () {}),
                _buildActionButton('Note', Icons.note_add, () {}),
                _buildActionButton('Copy', Icons.copy, () {}),
                _buildActionButton('Share', Icons.share, () {}),
                _buildActionButton('Image', Icons.image, () {}),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
