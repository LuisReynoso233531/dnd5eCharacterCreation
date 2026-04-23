// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CharacterClassImpl _$$CharacterClassImplFromJson(Map<String, dynamic> json) =>
    _$CharacterClassImpl(
      name: json['name'] as String,
      slug: json['slug'] as String,
      hpDie: (json['hp_die'] as num).toInt(),
    );

Map<String, dynamic> _$$CharacterClassImplToJson(
  _$CharacterClassImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'slug': instance.slug,
  'hp_die': instance.hpDie,
};
