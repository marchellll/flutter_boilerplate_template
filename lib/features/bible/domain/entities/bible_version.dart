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

  factory BibleVersion.fromMap(Map<String, dynamic> map) {
    return BibleVersion(
      id: map['id'] as String,
      name: map['name'] as String,
      fullName: map['full_name'] as String,
      language: map['language'] as String,
      description: map['description'] as String,
      isDefault: (map['is_default'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'language': language,
      'description': description,
      'is_default': isDefault ? 1 : 0,
    };
  }

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
