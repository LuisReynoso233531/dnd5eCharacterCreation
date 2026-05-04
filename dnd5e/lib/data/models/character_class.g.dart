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
      prof_armor: json['prof_armor'] as String?,
      prof_weapons: json['prof_weapons'] as String?,
      prof_tools: json['prof_tools'] as String?,
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
  'prof_armor': instance.prof_armor,
  'prof_weapons': instance.prof_weapons,
  'prof_tools': instance.prof_tools,
  'equipment': instance.equipment,
};
