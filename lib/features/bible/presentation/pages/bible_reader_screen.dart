import 'package:another_bible/features/bible/presentation/bloc/bible_reader_bloc.dart';
import 'package:another_bible/features/bible/presentation/widgets/navigation_modal.dart';
import 'package:another_bible/features/bible/presentation/widgets/version_picker_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/bible_reader_models.dart';

class BibleReaderScreen extends StatefulWidget {
  const BibleReaderScreen({super.key});

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<BibleReaderBloc>().add(const LoadInitialData());

    // Add scroll listener for auto-hide functionality
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Update scroll position in BLoC to handle bar visibility
    context.read<BibleReaderBloc>().add(UpdateScrollPosition(_scrollController.offset));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleReaderBloc, BibleReaderState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                // Swipe gestures for chapter navigation
                if (details.velocity.pixelsPerSecond.dx > 500) {
                  // Swipe right - previous chapter
                  context.read<BibleReaderBloc>().add(const NavigateToPreviousChapter());
                } else if (details.velocity.pixelsPerSecond.dx < -500) {
                  // Swipe left - next chapter
                  context.read<BibleReaderBloc>().add(const NavigateToNextChapter());
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
                    bottom: state.isMenuBarVisible ? 0 : -60,
                    left: 0,
                    right: 0,
                    child: _buildMenuBar(),
                  ),

                  // Floating Verse Pill FAB
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    bottom: state.isMenuBarVisible ? 80 : 20,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: _buildFloatingPill(state),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerseList(BibleReaderState state) {
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
                  // Book title + Chapter number with audio and settings buttons
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
                                      // TODO: Implement audio playback
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
                                      // TODO: Implement display settings modal
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
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor, // 100% opacity as requested
        border: Border(
          top: BorderSide(
            color: Colors.grey[600]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMenuButton(Icons.home, 'Home', () {}, false),
          _buildMenuButton(Icons.book, 'Bible', () {}, true), // Active item
          _buildMenuButton(Icons.calendar_today, 'Plans', () {}, false),
          _buildMenuButton(Icons.more_horiz, 'More', () {
            _showMoreModal();
          }, false),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String label, VoidCallback onTap, bool isActive) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? Colors.white : Colors.grey[600]
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.white : Colors.grey[600]
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingPill(BibleReaderState state) {
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
              onTap: () {
                VersionPickerModal.show(context);
              },
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
              onTap: () {
                NavigationModal.show(context);
              },
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

  void _showMoreModal() {
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
                const Text(
                  'More Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildMoreOption('Theme', Icons.palette, () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme settings coming soon!')),
                  );
                }),
                _buildMoreOption('Settings', Icons.settings, () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings coming soon!')),
                  );
                }),
                _buildMoreOption('Feedback', Icons.feedback, () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feedback coming soon!')),
                  );
                }),
                _buildMoreOption('Help', Icons.help, () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help coming soon!')),
                  );
                }),
                _buildMoreOption('About', Icons.info, () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('About coming soon!')),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOption(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
