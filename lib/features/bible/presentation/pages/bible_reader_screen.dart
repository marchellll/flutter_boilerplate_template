import 'package:another_bible/features/bible/presentation/bloc/bible_reader_bloc.dart';
import 'package:another_bible/features/bible/presentation/widgets/navigation_modal.dart';
import 'package:another_bible/features/bible/presentation/widgets/version_picker_modal.dart';
import 'package:another_bible/features/bible/presentation/widgets/verse_list_widget.dart';
import 'package:another_bible/features/bible/presentation/widgets/floating_pill_widget.dart';
import 'package:another_bible/core/widgets/app_bottom_navigation_bar.dart';
import 'package:another_bible/core/widgets/app_more_modal.dart';
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
                    child: VerseListWidget(
                      state: state,
                      scrollController: _scrollController,
                    ),
                  ),

                  // Menu Bar (Auto-hide) - No top bar as per guidelines
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: state.isMenuBarVisible ? 0 : -60,
                    left: 0,
                    right: 0,
                    child: AppBottomNavigationBar(
                      currentIndex: 1, // Bible is at index 1
                      onTap: (index) {
                        // Handle navigation between different sections
                        switch (index) {
                          case 0: // Home
                            break;
                          case 1: // Bible (current)
                            break;
                          case 2: // Plans
                            break;
                        }
                      },
                      onMoreTap: () => AppMoreModal.show(context),
                    ),
                  ),

                  // Floating Verse Pill FAB
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    bottom: state.isMenuBarVisible ? 80 : 20,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: FloatingPillWidget(
                        state: state,
                        onVersionTap: () => VersionPickerModal.show(context),
                        onNavigationTap: () => NavigationModal.show(context),
                      ),
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
}
