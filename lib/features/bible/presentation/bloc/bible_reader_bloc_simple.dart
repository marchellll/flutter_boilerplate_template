import 'package:flutter_bloc/flutter_bloc.dart';
import 'bible_reader_event.dart';
import 'bible_reader_state.dart';

class BibleReaderBloc extends Bloc<BibleReaderEvent, BibleReaderState> {
  BibleReaderBloc() : super(const BibleReaderState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<NavigateToNextChapter>(_onNavigateToNextChapter);
    on<NavigateToPreviousChapter>(_onNavigateToPreviousChapter);
    on<NavigateToReference>(_onNavigateToReference);
    on<ChangeVersion>(_onChangeVersion);
  }

  void _onLoadInitialData(LoadInitialData event, Emitter<BibleReaderState> emit) {
    emit(state.copyWith(isLoading: true));

    // Dummy Genesis 1 data
    final dummyVerses = [
      const VerseData(number: 1, text: "Pada mulanya Allah menciptakan langit dan bumi."),
      const VerseData(number: 2, text: "Bumi belum berbentuk dan kosong; gelap gulita menutupi samudera raya, dan Roh Allah melayang-layang di atas permukaan air."),
      const VerseData(number: 3, text: "Berfirmanlah Allah: \"Jadilah terang.\" Lalu terang itu jadi.", isHighlighted: true, highlightColor: "#FFF9C4"),
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

  void _onNavigateToReference(NavigateToReference event, Emitter<BibleReaderState> emit) {
    // For now, just handle Genesis
    emit(state.copyWith(
      currentChapter: event.chapterNumber,
      verses: _getDummyVersesForChapter(event.chapterNumber),
    ));
  }

  void _onChangeVersion(ChangeVersion event, Emitter<BibleReaderState> emit) {
    emit(state.copyWith(currentVersion: event.versionId));
  }

  List<VerseData> _getDummyVersesForChapter(int chapter) {
    if (chapter == 1) {
      return [
        const VerseData(number: 1, text: "Pada mulanya Allah menciptakan langit dan bumi."),
        const VerseData(number: 2, text: "Bumi belum berbentuk dan kosong; gelap gulita menutupi samudera raya, dan Roh Allah melayang-layang di atas permukaan air."),
        const VerseData(number: 3, text: "Berfirmanlah Allah: \"Jadilah terang.\" Lalu terang itu jadi.", isHighlighted: true, highlightColor: "#FFF9C4"),
        const VerseData(number: 4, text: "Allah melihat bahwa terang itu baik, lalu dipisahkan-Nyalah terang itu dari gelap."),
        const VerseData(number: 5, text: "Dan Allah menamai terang itu siang, dan gelap itu malam. Jadilah petang dan jadilah pagi, itulah hari pertama.", hasNote: true),
      ];
    } else {
      return [
        VerseData(number: 1, text: "Ini adalah Kejadian pasal $chapter, ayat 1. Lorem ipsum dolor sit amet."),
        VerseData(number: 2, text: "Ayat kedua dari pasal $chapter dengan teks yang lebih panjang untuk testing."),
        VerseData(number: 3, text: "Ayat ketiga dari pasal $chapter untuk demonstrasi navigasi."),
      ];
    }
  }
}
