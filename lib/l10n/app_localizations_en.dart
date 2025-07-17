// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Todo App';

  @override
  String get todoList => 'Todo List';

  @override
  String get addTodo => 'Add Todo';

  @override
  String get editTodo => 'Edit Todo';

  @override
  String get deleteTodo => 'Delete Todo';

  @override
  String get todoTitle => 'Todo Title';

  @override
  String get todoDescription => 'Todo Description';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get markAsCompleted => 'Mark as Completed';

  @override
  String get markAsIncomplete => 'Mark as Incomplete';

  @override
  String get noTodos => 'No todos yet. Add one!';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get settings => 'Settings';

  @override
  String get debugScreen => 'Debug Screen';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get indonesian => 'Indonesian';
}
