import 'package:freezed_annotation/freezed_annotation.dart';

part 'character_class.freezed.dart';
part 'character_class.g.dart';

@freezed
class CharacterClass with _$CharacterClass {
  const factory CharacterClass({
    required String name,
    required String slug,
    required String hit_dice, 
    required String prof_saving_throws,
    required String? prof_skills,
    required String? prof_armor,
    required String? prof_weapons,
    required String? prof_tools,
    required String? equipment,
  }) = _CharacterClass;

  factory CharacterClass.fromJson(Map<String, dynamic> json) => 
      _$CharacterClassFromJson(json);
}