import 'package:freezed_annotation/freezed_annotation.dart';
// Debes importar el modelo de la clase para que Character lo reconozca
import 'character_class.dart'; 

part 'character.freezed.dart';
part 'character.g.dart';

@freezed
class Character with _$Character {
  const factory Character({
    String? id,
    required String name,
    required String race,
    required CharacterClass characterClass,
    required int level,
    required int strength,
    required int dexterity,
    required int constitution,
    required int intelligence,
    required int wisdom,
    required int charisma,
    @Default([]) List<String> equipment,
  }) = _Character;

  factory Character.fromJson(Map<String, dynamic> json) => 
      _$CharacterFromJson(json);
}