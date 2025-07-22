import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bible_reader_bloc.dart';

class NavigationModal {
  static void show(BuildContext context) {
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
                            _DirectNavigationTab(),
                            _DialerNavigationTab(),
                            _GridNavigationTab(scrollController: scrollController),
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
}

class _DirectNavigationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              _navigateToReference(context, value);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _navigateToReference(context, controller.text);
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

  void _navigateToReference(BuildContext context, String reference) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to: $reference')),
    );
  }
}

class _DialerNavigationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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

  List<String> _getBookList() {
    return [
      'Kejadian', 'Keluaran', 'Imamat', 'Bilangan', 'Ulangan',
      'Yosua', 'Hakim-hakim', 'Rut', '1 Samuel', '2 Samuel',
      // Add more books as needed
    ];
  }
}

class _GridNavigationTab extends StatelessWidget {
  final ScrollController scrollController;

  const _GridNavigationTab({required this.scrollController});

  @override
  Widget build(BuildContext context) {
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
                    context.read<BibleReaderBloc>().add(NavigateToChapter(chapter));
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
}
