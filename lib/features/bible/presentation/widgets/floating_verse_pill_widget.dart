import 'package:flutter/material.dart';
import '../bloc/bible_reader_state.dart';

class FloatingVersePillWidget extends StatelessWidget {
  final BibleReaderLoaded state;
  final bool isDimmed;

  const FloatingVersePillWidget({
    super.key,
    required this.state,
    required this.isDimmed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showNavigationModal(context),
      onPanUpdate: (details) {
        // TODO: Implement drag to expand functionality
      },
      child: AnimatedOpacity(
        opacity: isDimmed ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 200),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.currentVersion.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                ' | ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                '${state.currentBook.nameLocal} ${state.currentChapter}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNavigationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _NavigationModal(state: state),
    );
  }
}

class _NavigationModal extends StatefulWidget {
  final BibleReaderLoaded state;

  const _NavigationModal({required this.state});

  @override
  State<_NavigationModal> createState() => _NavigationModalState();
}

class _NavigationModalState extends State<_NavigationModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Direct and Grid modes
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.7,
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Navigate',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Direct'),
              Tab(text: 'Grid'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _DirectDialerTab(state: widget.state),
                _GridTab(state: widget.state),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectDialerTab extends StatefulWidget {
  final BibleReaderLoaded state;

  const _DirectDialerTab({required this.state});

  @override
  State<_DirectDialerTab> createState() => _DirectDialerTabState();
}

class _DirectDialerTabState extends State<_DirectDialerTab> {
  final TextEditingController _bookController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  @override
  void dispose() {
    _bookController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Book selector and reference input
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _bookController,
                  decoration: const InputDecoration(
                    labelText: 'Book',
                    hintText: 'Genesis, Gen, Kejadian...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // TODO: Show book suggestions
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Chapter:Verse',
                    hintText: '1:1',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // TODO: Parse and validate reference
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Numeric keypad (simplified for now)
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: [
                ...List.generate(9, (index) => _NumberButton('${index + 1}')),
                _NumberButton(':'),
                _NumberButton('0'),
                _NumberButton('⌫'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Go button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to reference
                Navigator.of(context).pop();
              },
              child: const Text('Go'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final String text;

  const _NumberButton(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Handle number input
        },
        child: Text(text),
      ),
    );
  }
}

class _GridTab extends StatelessWidget {
  final BibleReaderLoaded state;

  const _GridTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Grid navigation coming soon',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'This will show a grid of chapters and verses for quick navigation.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
