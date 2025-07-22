import 'package:equatable/equatable.dart';

class BibleVersion extends Equatable {
  final String id;
  final String name;
  final String fullName;
  final String language;
  final String description;
  final bool isDefault;

  const BibleVersion({
    required this.id,
    required this.name,
    required this.fullName,
    required this.language,
    required this.description,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        fullName,
        language,
        description,
        isDefault,
      ];
}
