// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CharacterImpl _$$CharacterImplFromJson(Map<String, dynamic> json) =>
    _$CharacterImpl(
      id: json['id'] as String?,
      name: json['name'] as String,
      race: json['race'] as String,
      characterClass: CharacterClass.fromJson(
        json['characterClass'] as Map<String, dynamic>,
      ),
      level: (json['level'] as num).toInt(),
      strength: (json['strength'] as num).toInt(),
      dexterity: (json['dexterity'] as num).toInt(),
      constitution: (json['constitution'] as num).toInt(),
      intelligence: (json['intelligence'] as num).toInt(),
      wisdom: (json['wisdom'] as num).toInt(),
      charisma: (json['charisma'] as num).toInt(),
      equipment:
          (json['equipment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CharacterImplToJson(_$CharacterImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'race': instance.race,
      'characterClass': instance.characterClass,
      'level': instance.level,
      'strength': instance.strength,
      'dexterity': instance.dexterity,
      'constitution': instance.constitution,
      'intelligence': instance.intelligence,
      'wisdom': instance.wisdom,
      'charisma': instance.charisma,
      'equipment': instance.equipment,
    };
