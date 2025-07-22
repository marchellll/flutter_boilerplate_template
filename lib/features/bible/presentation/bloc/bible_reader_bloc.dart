import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../models/bible_reader_models.dart';

// Events
abstract class BibleReaderEvent extends Equatable {
  const BibleReaderEvent();
  @override
  List<Object?> get props => [];
}

class LoadInitialData extends BibleReaderEvent {
  const LoadInitialData();
}

class NavigateToNextChapter extends BibleReaderEvent {
  const NavigateToNextChapter();
}

class NavigateToPreviousChapter extends BibleReaderEvent {
  const NavigateToPreviousChapter();
}

class NavigateToChapter extends BibleReaderEvent {
  final int chapter;
  const NavigateToChapter(this.chapter);

  @override
  List<Object?> get props => [chapter];
}

class ToggleBars extends BibleReaderEvent {
  const ToggleBars();
}

class UpdateScrollPosition extends BibleReaderEvent {
  final double scrollOffset;
  const UpdateScrollPosition(this.scrollOffset);

  @override
  List<Object?> get props => [scrollOffset];
}

// BLoC
@injectable
class BibleReaderBloc extends Bloc<BibleReaderEvent, BibleReaderState> {
  BibleReaderBloc() : super(const BibleReaderState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<NavigateToNextChapter>(_onNavigateToNextChapter);
    on<NavigateToPreviousChapter>(_onNavigateToPreviousChapter);
    on<NavigateToChapter>(_onNavigateToChapter);
    on<ToggleBars>(_onToggleBars);
    on<UpdateScrollPosition>(_onUpdateScrollPosition);
  }

  void _onLoadInitialData(LoadInitialData event, Emitter<BibleReaderState> emit) {
    emit(state.copyWith(isLoading: true));

    // Dummy Genesis 1 data - Indonesian version
    final dummyVerses = [
      const VerseData(number: 1, text: "Pada mulanya Allah menciptakan langit dan bumi."),
      const VerseData(number: 2, text: "Bumi belum berbentuk dan kosong; gelap gulita menutupi samudera raya, dan Roh Allah melayang-layang di atas permukaan air."),
      const VerseData(number: 3, text: "Berfirmanlah Allah: \"Jadilah terang.\" Lalu terang itu jadi.", isHighlighted: true, highlightColor: "#FFE082"),
      const VerseData(number: 4, text: "Allah melihat bahwa terang itu baik, lalu dipisahkan-Nyalah terang itu dari gelap."),
      const VerseData(number: 5, text: "Dan Allah menamai terang itu siang, dan gelap itu malam. Jadilah petang dan jadilah pagi, itulah hari pertama.", hasNote: true),
      const VerseData(number: 6, text: "Berfirmanlah Allah: \"Jadilah cakrawala di tengah segala air untuk memisahkan air dari air.\""),
      const VerseData(number: 7, text: "Maka Allah menjadikan cakrawala dan memisahkan air yang ada di bawah cakrawala itu dari air yang ada di atasnya. Dan jadilah demikian."),
      const VerseData(number: 8, text: "Lalu Allah menamai cakrawala itu langit. Jadilah petang dan jadilah pagi, itulah hari kedua."),
      const VerseData(number: 9, text: "Berfirmanlah Allah: \"Hendaklah segala air yang di bawah langit berkumpul pada satu tempat, sehingga kelihatan yang kering.\" Dan jadilah demikian."),
      const VerseData(number: 10, text: "Lalu Allah menamai yang kering itu darat, dan kumpulan air itu dinamai-Nya laut. Allah melihat bahwa semuanya itu baik."),
    ];

    emit(state.copyWith(
      verses: dummyVerses,
      isLoading: false,
    ));
  }

  void _onNavigateToNextChapter(NavigateToNextChapter event, Emitter<BibleReaderState> emit) {
    if (state.currentBook == 'Genesis' && state.currentChapter < 50) {
      emit(state.copyWith(
        currentChapter: state.currentChapter + 1,
        verses: _getDummyVersesForChapter(state.currentChapter + 1),
      ));
    }
  }

  void _onNavigateToPreviousChapter(NavigateToPreviousChapter event, Emitter<BibleReaderState> emit) {
    if (state.currentChapter > 1) {
      emit(state.copyWith(
        currentChapter: state.currentChapter - 1,
        verses: _getDummyVersesForChapter(state.currentChapter - 1),
      ));
    }
  }

  void _onNavigateToChapter(NavigateToChapter event, Emitter<BibleReaderState> emit) {
    if (event.chapter >= 1 && event.chapter <= 50) { // Genesis has 50 chapters
      emit(state.copyWith(
        currentChapter: event.chapter,
        verses: _getDummyVersesForChapter(event.chapter),
      ));
    }
  }

  void _onToggleBars(ToggleBars event, Emitter<BibleReaderState> emit) {
    emit(state.copyWith(
      isTopBarVisible: !state.isTopBarVisible,
      isMenuBarVisible: !state.isMenuBarVisible,
    ));
  }

  void _onUpdateScrollPosition(UpdateScrollPosition event, Emitter<BibleReaderState> emit) {
    // Show bars when at the top (scroll offset < 100), hide when scrolled down
    final bool shouldShowBars = event.scrollOffset < 100;

    // Only emit if the visibility state changes to avoid unnecessary rebuilds
    if (shouldShowBars != state.isMenuBarVisible || shouldShowBars != state.isTopBarVisible) {
      emit(state.copyWith(
        isTopBarVisible: shouldShowBars,
        isMenuBarVisible: shouldShowBars,
      ));
    }
  }

  List<VerseData> _getDummyVersesForChapter(int chapter) {
    if (chapter == 1) {
      return [
        const VerseData(number: 1, text: "Pada mulanya Allah menciptakan langit dan bumi."),
        const VerseData(number: 2, text: "Bumi belum berbentuk dan kosong; gelap gulita menutupi samudera raya, dan Roh Allah melayang-layang di atas permukaan air."),
        const VerseData(number: 3, text: "Berfirmanlah Allah: \"Jadilah terang.\" Lalu terang itu jadi.", isHighlighted: true, highlightColor: "#FFE082"),
        const VerseData(number: 4, text: "Allah melihat bahwa terang itu baik, lalu dipisahkan-Nyalah terang itu dari gelap."),
        const VerseData(number: 5, text: "Dan Allah menamai terang itu siang, dan gelap itu malam. Jadilah petang dan jadilah pagi, itulah hari pertama.", hasNote: true),
      ];
    } else {
      return [
        VerseData(number: 1, text: "Ini adalah ${state.currentBookLocal} pasal $chapter, ayat 1. Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        VerseData(number: 2, text: "Ayat kedua dari pasal $chapter dengan teks yang lebih panjang untuk testing scrolling dan layout."),
        VerseData(number: 3, text: "Ayat ketiga dari pasal $chapter untuk demonstrasi navigasi antar pasal dengan gesture."),
        VerseData(number: 4, text: "Ayat keempat menunjukkan bagaimana verse numbers ditampilkan sebagai superscript."),
        VerseData(number: 5, text: "Ayat kelima dengan teks yang cukup panjang untuk menguji line spacing dan typography sesuai dengan guidelines design."),
      ];
    }
  }
}
