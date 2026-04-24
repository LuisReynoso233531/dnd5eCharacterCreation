import 'package:freezed_annotation/freezed_annotation.dart';

part 'character_class.freezed.dart';
part 'character_class.g.dart';

@freezed
class CharacterClass with _$CharacterClass {
  const factory CharacterClass({
    required String name,
    required String slug,
    // Usamos hit_dice porque así lo estás llamando en tu pantalla de selección
    required String hit_dice, 
    required String prof_saving_throws,
  }) = _CharacterClass;

  factory CharacterClass.fromJson(Map<String, dynamic> json) => 
      _$CharacterClassFromJson(json);
}