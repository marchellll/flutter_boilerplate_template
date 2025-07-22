import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_books.dart';
import '../../domain/usecases/get_verses.dart';
import '../../domain/usecases/get_bible_versions.dart';
import '../../domain/repositories/bible_repository.dart';
import '../../domain/entities/highlight.dart';
import '../../domain/entities/note.dart';
import 'bible_reader_event.dart';
import 'bible_reader_state.dart';

@injectable
class BibleReaderBloc extends Bloc<BibleReaderEvent, BibleReaderState> {
  final GetBooks _getBooks;
  final GetVerses _getVerses;
  final GetBibleVersions _getBibleVersions;
  final BibleRepository _repository;

  BibleReaderBloc(
    this._getBooks,
    this._getVerses,
    this._getBibleVersions,
    this._repository,
  ) : super(const BibleReaderInitial()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<LoadChapter>(_onLoadChapter);
    on<NavigateToNextChapter>(_onNavigateToNextChapter);
    on<NavigateToPreviousChapter>(_onNavigateToPreviousChapter);
    on<NavigateToReference>(_onNavigateToReference);
    on<ChangeVersion>(_onChangeVersion);
    on<AddHighlight>(_onAddHighlight);
    on<AddNote>(_onAddNote);
  }

  Future<void> _onLoadInitialData(
    LoadInitialData event,
    Emitter<BibleReaderState> emit,
  ) async {
    emit(const BibleReaderLoading());

    try {
      // Load all required data
      final booksResult = await _getBooks();
      final versionsResult = await _getBibleVersions();
      final defaultVersionResult = await _repository.getDefaultVersion();

      booksResult.fold(
        (failure) => emit(BibleReaderError(failure.message)),
        (books) async {
          versionsResult.fold(
            (failure) => emit(BibleReaderError(failure.message)),
            (versions) async {
              defaultVersionResult.fold(
                (failure) => emit(BibleReaderError(failure.message)),
                (defaultVersion) async {
                  final version = defaultVersion ?? versions.first;
                  final firstBook = books.first;

                  // Load Genesis Chapter 1 by default
                  final versesResult = await _getVerses(
                    bookId: firstBook.id,
                    chapterNumber: 1,
                    versionId: version.id,
                  );

                  versesResult.fold(
                    (failure) => emit(BibleReaderError(failure.message)),
                    (verses) async {
                      // Load highlights and notes for this chapter
                      final highlightsResult = await _repository.getHighlightsForChapter(
                        firstBook.id,
                        1,
                      );
                      final notesResult = await _repository.getNotesForChapter(
                        firstBook.id,
                        1,
                      );

                      final highlights = highlightsResult.fold(
                        (l) => <Highlight>[],
                        (r) => r,
                      );
                      final notes = notesResult.fold(
                        (l) => <Note>[],
                        (r) => r,
                      );

                      emit(BibleReaderLoaded(
                        currentBook: firstBook,
                        currentChapter: 1,
                        verses: verses,
                        currentVersion: version,
                        availableVersions: versions,
                        books: books,
                        highlights: highlights,
                        notes: notes,
                      ));
                    },
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(BibleReaderError('Failed to load initial data: ${e.toString()}'));
    }
  }

  Future<void> _onLoadChapter(
    LoadChapter event,
    Emitter<BibleReaderState> emit,
  ) async {
    if (state is BibleReaderLoaded) {
      final currentState = state as BibleReaderLoaded;
      emit(const BibleReaderLoading());

      try {
        final bookResult = await _repository.getBookById(event.bookId);
        final versesResult = await _getVerses(
          bookId: event.bookId,
          chapterNumber: event.chapterNumber,
          versionId: event.versionId,
        );

        bookResult.fold(
          (failure) => emit(BibleReaderError(failure.message)),
          (book) async {
            if (book == null) {
              emit(const BibleReaderError('Book not found'));
              return;
            }

            versesResult.fold(
              (failure) => emit(BibleReaderError(failure.message)),
              (verses) async {
                // Load highlights and notes for this chapter
                final highlightsResult = await _repository.getHighlightsForChapter(
                  event.bookId,
                  event.chapterNumber,
                );
                final notesResult = await _repository.getNotesForChapter(
                  event.bookId,
                  event.chapterNumber,
                );

                final highlights = highlightsResult.fold(
                  (l) => <Highlight>[],
                  (r) => r,
                );
                final notes = notesResult.fold(
                  (l) => <Note>[],
                  (r) => r,
                );

                emit(currentState.copyWith(
                  currentBook: book,
                  currentChapter: event.chapterNumber,
                  verses: verses,
                  highlights: highlights,
                  notes: notes,
                ));
              },
            );
          },
        );
      } catch (e) {
        emit(BibleReaderError('Failed to load chapter: ${e.toString()}'));
      }
    }
  }

  Future<void> _onNavigateToNextChapter(
    NavigateToNextChapter event,
    Emitter<BibleReaderState> emit,
  ) async {
    if (state is BibleReaderLoaded) {
      final currentState = state as BibleReaderLoaded;
      final currentBook = currentState.currentBook;
      final currentChapter = currentState.currentChapter;

      if (currentChapter < currentBook.chapterCount) {
        // Next chapter in the same book
        add(LoadChapter(
          bookId: currentBook.id,
          chapterNumber: currentChapter + 1,
          versionId: currentState.currentVersion.id,
        ));
      } else {
        // Next book, chapter 1
        final books = currentState.books;
        final currentBookIndex = books.indexWhere((book) => book.id == currentBook.id);
        if (currentBookIndex < books.length - 1) {
          final nextBook = books[currentBookIndex + 1];
          add(LoadChapter(
            bookId: nextBook.id,
            chapterNumber: 1,
            versionId: currentState.currentVersion.id,
          ));
        }
      }
    }
  }

  Future<void> _onNavigateToPreviousChapter(
    NavigateToPreviousChapter event,
    Emitter<BibleReaderState> emit,
  ) async {
    if (state is BibleReaderLoaded) {
      final currentState = state as BibleReaderLoaded;
      final currentBook = currentState.currentBook;
      final currentChapter = currentState.currentChapter;

      if (currentChapter > 1) {
        // Previous chapter in the same book
        add(LoadChapter(
          bookId: currentBook.id,
          chapterNumber: currentChapter - 1,
          versionId: currentState.currentVersion.id,
        ));
      } else {
        // Previous book, last chapter
        final books = currentState.books;
        final currentBookIndex = books.indexWhere((book) => book.id == currentBook.id);
        if (currentBookIndex > 0) {
          final previousBook = books[currentBookIndex - 1];
          add(LoadChapter(
            bookId: previousBook.id,
            chapterNumber: previousBook.chapterCount,
            versionId: currentState.currentVersion.id,
          ));
        }
      }
    }
  }

  Future<void> _onNavigateToReference(
    NavigateToReference event,
    Emitter<BibleReaderState> emit,
  ) async {
    if (state is BibleReaderLoaded) {
      final currentState = state as BibleReaderLoaded;
      add(LoadChapter(
        bookId: event.bookId,
        chapterNumber: event.chapterNumber,
        versionId: currentState.currentVersion.id,
      ));
    }
  }

  Future<void> _onChangeVersion(
    ChangeVersion event,
    Emitter<BibleReaderState> emit,
  ) async {
    if (state is BibleReaderLoaded) {
      final currentState = state as BibleReaderLoaded;
      final newVersion = currentState.availableVersions
          .firstWhere((version) => version.id == event.versionId);

      add(LoadChapter(
        bookId: currentState.currentBook.id,
        chapterNumber: currentState.currentChapter,
        versionId: event.versionId,
      ));

      emit(currentState.copyWith(currentVersion: newVersion));
    }
  }

  Future<void> _onAddHighlight(
    AddHighlight event,
    Emitter<BibleReaderState> emit,
  ) async {
    if (state is BibleReaderLoaded) {
      final currentState = state as BibleReaderLoaded;
      final result = await _repository.addHighlight(event.highlight);

      result.fold(
        (failure) => emit(BibleReaderError(failure.message)),
        (_) {
          // Reload highlights for current chapter
          add(LoadChapter(
            bookId: currentState.currentBook.id,
            chapterNumber: currentState.currentChapter,
            versionId: currentState.currentVersion.id,
          ));
        },
      );
    }
  }

  Future<void> _onAddNote(
    AddNote event,
    Emitter<BibleReaderState> emit,
  ) async {
    if (state is BibleReaderLoaded) {
      final currentState = state as BibleReaderLoaded;
      final result = await _repository.addNote(event.note);

      result.fold(
        (failure) => emit(BibleReaderError(failure.message)),
        (_) {
          // Reload notes for current chapter
          add(LoadChapter(
            bookId: currentState.currentBook.id,
            chapterNumber: currentState.currentChapter,
            versionId: currentState.currentVersion.id,
          ));
        },
      );
    }
  }
}
