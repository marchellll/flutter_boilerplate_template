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
    context.read<SimpleBibleBloc>().add(UpdateScrollPosition(_scrollController.offset));
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

  Widget _buildFloatingPill(SimpleBibleState state) {
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
                _showVersionPicker();
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
                _showNavigationModal();
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

  void _showNavigationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Navigate to',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Tab navigation
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey[600],
                        indicatorColor: Theme.of(context).primaryColor,
                        tabs: const [
                          Tab(text: 'Direct'),
                          Tab(text: 'Dialer'),
                          Tab(text: 'Grid'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildDirectNavigationTab(),
                            _buildDialerNavigationTab(),
                            _buildGridNavigationTab(scrollController),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectNavigationTab() {
    final TextEditingController controller = TextEditingController();
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Enter reference (e.g., "Mat 6:9" or "Genesis 1:1")',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Mat 6:9',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            textInputAction: TextInputAction.go,
            onSubmitted: (value) {
              _navigateToReference(value);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _navigateToReference(controller.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Go', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialerNavigationTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Select book, chapter, and verse',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                // Book picker
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const Text('Book', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: _getBookList().length,
                            itemBuilder: (context, index) {
                              final book = _getBookList()[index];
                              return ListTile(
                                title: Text(book, style: const TextStyle(fontSize: 14)),
                                onTap: () {
                                  // Handle book selection
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Chapter picker
                Expanded(
                  child: Column(
                    children: [
                      const Text('Chapter', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: 50, // Example: Genesis has 50 chapters
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text('${index + 1}', style: const TextStyle(fontSize: 14)),
                                onTap: () {
                                  // Handle chapter selection
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Verse picker
                Expanded(
                  child: Column(
                    children: [
                      const Text('Verse', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: 31, // Example: Genesis 1 has 31 verses
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text('${index + 1}', style: const TextStyle(fontSize: 14)),
                                onTap: () {
                                  // Handle verse selection
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to selected reference
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Go to Selected', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridNavigationTab(ScrollController scrollController) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Select a chapter',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: 50, // Example: Genesis has 50 chapters
              itemBuilder: (context, index) {
                final chapter = index + 1;
                return InkWell(
                  onTap: () {
                    // Navigate to chapter
                    context.read<SimpleBibleBloc>().add(NavigateToChapter(chapter));
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: chapter == 1 // Current chapter (example)
                          ? Theme.of(context).primaryColor
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$chapter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: chapter == 1 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getBookList() {
    return [
      'Kejadian', 'Keluaran', 'Imamat', 'Bilangan', 'Ulangan',
      'Yosua', 'Hakim-hakim', 'Rut', '1 Samuel', '2 Samuel',
      // Add more books as needed
    ];
  }

  void _showVersionPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Bible Version',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Scrollable version list
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Downloaded/Available versions section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Available',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildVersionOption('TSI', 'Terjemahan Sederhana Indonesia', true),
                      _buildVersionOption('TB', 'Terjemahan Baru', false),
                      _buildVersionOption('KJV', 'King James Version', false),
                      _buildVersionOption('NIV', 'New International Version', false),
                      _buildVersionOption('ESV', 'English Standard Version', false),
                      _buildVersionOption('NASB', 'New American Standard Bible', false),
                      _buildVersionOption('NLT', 'New Living Translation', false),
                      _buildVersionOption('MSG', 'The Message', false),
                      
                      const SizedBox(height: 24),
                      
                      // More versions section
                      _buildMoreVersionsOption(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreVersionsOption() {
    return Column(
      children: [
        // Horizontal separator line
        Container(
          height: 0.5,
          width: double.infinity,
          color: Colors.grey[300],
          margin: const EdgeInsets.symmetric(vertical: 16),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
            _showImportVersionModal();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.download,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'More versions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Download or import Bible versions',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showImportVersionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'More Versions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Import from file section
                      _buildImportSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Available downloads section
                      const Text(
                        'Available Downloads',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      _buildDownloadableVersion('AMP', 'Amplified Bible', '2.1 MB'),
                      _buildDownloadableVersion('NKJV', 'New King James Version', '1.8 MB'),
                      _buildDownloadableVersion('CEV', 'Contemporary English Version', '1.7 MB'),
                      _buildDownloadableVersion('GNT', 'Good News Translation', '1.9 MB'),
                      _buildDownloadableVersion('HCSB', 'Holman Christian Standard Bible', '2.0 MB'),
                      _buildDownloadableVersion('ISV', 'International Standard Version', '2.2 MB'),
                      _buildDownloadableVersion('NET', 'New English Translation', '2.3 MB'),
                      _buildDownloadableVersion('RSV', 'Revised Standard Version', '1.9 MB'),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Import from File',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Import Bible files in formats: USFM, USX, OSIS, YES, PBD',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File picker coming soon!')),
                );
              },
              icon: const Icon(Icons.file_upload),
              label: const Text('Choose File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadableVersion(String code, String name, String size) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloading $code...')),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.download,
                  color: Colors.green[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                size,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.download, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionOption(String code, String name, bool isSelected) {
    return InkWell(
      onTap: () {
        // Handle version selection
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected $code version')),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  code,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue : null,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToReference(String reference) {
    // Parse reference like "Mat 6:9" or "Genesis 1:1"
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to: $reference')),
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
