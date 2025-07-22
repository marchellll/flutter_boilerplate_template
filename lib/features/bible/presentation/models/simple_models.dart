import 'package:equatable/equatable.dart';

class VerseData extends Equatable {
  final int number;
  final String text;
  final bool isHighlighted;
  final String? highlightColor;
  final bool hasNote;

  const VerseData({
    required this.number,
    required this.text,
    this.isHighlighted = false,
    this.highlightColor,
    this.hasNote = false,
  });

  @override
  List<Object?> get props => [number, text, isHighlighted, highlightColor, hasNote];
}

class SimpleBibleState extends Equatable {
  final String currentBook;
  final String currentBookLocal;
  final int currentChapter;
  final String currentVersion;
  final List<VerseData> verses;
  final bool isLoading;
  final bool isTopBarVisible;
  final bool isMenuBarVisible;
  final String? error;

  const SimpleBibleState({
    this.currentBook = 'Genesis',
    this.currentBookLocal = 'Kejadian',
    this.currentChapter = 1,
    this.currentVersion = 'TSI',
    this.verses = const [],
    this.isLoading = false,
    this.isTopBarVisible = true,
    this.isMenuBarVisible = true,
    this.error,
  });

  SimpleBibleState copyWith({
    String? currentBook,
    String? currentBookLocal,
    int? currentChapter,
    String? currentVersion,
    List<VerseData>? verses,
    bool? isLoading,
    bool? isTopBarVisible,
    bool? isMenuBarVisible,
    String? error,
  }) {
    return SimpleBibleState(
      currentBook: currentBook ?? this.currentBook,
      currentBookLocal: currentBookLocal ?? this.currentBookLocal,
      currentChapter: currentChapter ?? this.currentChapter,
      currentVersion: currentVersion ?? this.currentVersion,
      verses: verses ?? this.verses,
      isLoading: isLoading ?? this.isLoading,
      isTopBarVisible: isTopBarVisible ?? this.isTopBarVisible,
      isMenuBarVisible: isMenuBarVisible ?? this.isMenuBarVisible,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        currentBook,
        currentBookLocal,
        currentChapter,
        currentVersion,
        verses,
        isLoading,
        isTopBarVisible,
        isMenuBarVisible,
        error,
      ];
}
