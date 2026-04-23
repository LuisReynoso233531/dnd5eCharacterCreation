import 'package:freezed_annotation/freezed_annotation.dart';

// Importante: El nombre debe coincidir con el nombre del archivo .dart
part 'character_class.freezed.dart';
part 'character_class.g.dart';

@freezed
class CharacterClass with _$CharacterClass {
  const factory CharacterClass({
    required String name,
    required String slug,
    @JsonKey(name: 'hp_die') required int hpDie,
  }) = _CharacterClass;

  factory CharacterClass.fromJson(Map<String, dynamic> json) => 
      _$CharacterClassFromJson(json);
}