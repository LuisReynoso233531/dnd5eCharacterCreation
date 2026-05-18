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
    required String? desc,
    required String? table,
    @Default('') String hp_at_1st_level,
    @Default('') String hp_at_higher_levels,
    @Default('') String spellcasting_ability,
    @Default('') String subtypes_name,
    @Default([]) List<Map<String, dynamic>> archetypes,
  }) = _CharacterClass;

  factory CharacterClass.fromJson(Map<String, dynamic> json) =>
      _$CharacterClassFromJson(json);
}
