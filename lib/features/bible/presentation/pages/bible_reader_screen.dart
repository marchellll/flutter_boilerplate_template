import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bible_reader_bloc.dart';
import '../bloc/bible_reader_event.dart';
import '../bloc/bible_reader_state.dart';
import '../widgets/verse_list_widget.dart';
import '../widgets/top_bar_widget.dart';
import '../widgets/menu_bar_widget.dart';
import '../widgets/floating_verse_pill_widget.dart';

class BibleReaderScreen extends StatefulWidget {
  const BibleReaderScreen({super.key});

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isTopBarVisible = true;
  
  @override
  void initState() {
    super.initState();
    context.read<BibleReaderBloc>().add(const LoadInitialData());
    
    _scrollController.addListener(() {
      final isAtTop = _scrollController.offset <= 100;
      final isScrollingUp = _scrollController.position.userScrollDirection == ScrollDirection.forward;
      
      if (isAtTop || isScrollingUp) {
        if (!_isTopBarVisible) {
          setState(() {
            _isTopBarVisible = true;
          });
        }
      } else {
        if (_isTopBarVisible) {
          setState(() {
            _isTopBarVisible = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<BibleReaderBloc, BibleReaderState>(
          builder: (context, state) {
            if (state is BibleReaderLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (state is BibleReaderError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BibleReaderBloc>().add(const LoadInitialData());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is BibleReaderLoaded) {
              return Stack(
                children: [
                  // Main content - verses
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 60, // Space for top bar
                      bottom: 80, // Space for menu bar
                    ),
                    child: VerseListWidget(
                      scrollController: _scrollController,
                      state: state,
                    ),
                  ),
                  
                  // Top Bar (auto-hide)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: _isTopBarVisible ? 0 : -60,
                    left: 0,
                    right: 0,
                    child: TopBarWidget(state: state),
                  ),
                  
                  // Menu Bar (auto-hide)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: _isTopBarVisible ? 0 : -80,
                    left: 0,
                    right: 0,
                    child: MenuBarWidget(isVisible: _isTopBarVisible),
                  ),
                  
                  // Floating Verse Pill FAB
                  Positioned(
                    bottom: _isTopBarVisible ? 90 : 20,
                    right: 20,
                    child: FloatingVersePillWidget(
                      state: state,
                      isDimmed: !_isTopBarVisible,
                    ),
                  ),
                ],
              );
            }
            
            return const Center(
              child: Text('Initializing...'),
            );
          },
        ),
      ),
    );
  }
}
