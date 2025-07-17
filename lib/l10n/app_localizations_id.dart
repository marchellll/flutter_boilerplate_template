// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Aplikasi Todo';

  @override
  String get todoList => 'Daftar Todo';

  @override
  String get addTodo => 'Tambah Todo';

  @override
  String get editTodo => 'Edit Todo';

  @override
  String get deleteTodo => 'Hapus Todo';

  @override
  String get todoTitle => 'Judul Todo';

  @override
  String get todoDescription => 'Deskripsi Todo';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get markAsCompleted => 'Tandai Selesai';

  @override
  String get markAsIncomplete => 'Tandai Belum Selesai';

  @override
  String get noTodos => 'Belum ada todo. Tambah satu!';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get lightMode => 'Mode Terang';

  @override
  String get settings => 'Pengaturan';

  @override
  String get debugScreen => 'Layar Debug';

  @override
  String get language => 'Bahasa';

  @override
  String get english => 'Bahasa Inggris';

  @override
  String get indonesian => 'Bahasa Indonesia';
}
