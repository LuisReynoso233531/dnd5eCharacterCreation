// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CharacterClassImpl _$$CharacterClassImplFromJson(Map<String, dynamic> json) =>
    _$CharacterClassImpl(
      name: json['name'] as String,
      slug: json['slug'] as String,
      hit_dice: json['hit_dice'] as String,
      prof_saving_throws: json['prof_saving_throws'] as String,
      prof_skills: json['prof_skills'] as String?,
      armor_proficiencies: json['armor_proficiencies'] as String?,
      weapon_proficiencies: json['weapon_proficiencies'] as String?,
      tool_proficiencies: json['tool_proficiencies'] as String?,
      equipment: json['equipment'] as String?,
    );

Map<String, dynamic> _$$CharacterClassImplToJson(
  _$CharacterClassImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'slug': instance.slug,
  'hit_dice': instance.hit_dice,
  'prof_saving_throws': instance.prof_saving_throws,
  'prof_skills': instance.prof_skills,
  'armor_proficiencies': instance.armor_proficiencies,
  'weapon_proficiencies': instance.weapon_proficiencies,
  'tool_proficiencies': instance.tool_proficiencies,
  'equipment': instance.equipment,
};
