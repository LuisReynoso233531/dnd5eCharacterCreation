// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'character.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Character _$CharacterFromJson(Map<String, dynamic> json) {
  return _Character.fromJson(json);
}

/// @nodoc
mixin _$Character {
  String? get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get race => throw _privateConstructorUsedError;
  CharacterClass get characterClass =>
      throw _privateConstructorUsedError; // Ya contiene hit_dice y profs
  int get level => throw _privateConstructorUsedError;
  int get strength => throw _privateConstructorUsedError;
  int get dexterity => throw _privateConstructorUsedError;
  int get constitution => throw _privateConstructorUsedError;
  int get intelligence => throw _privateConstructorUsedError;
  int get wisdom => throw _privateConstructorUsedError;
  int get charisma => throw _privateConstructorUsedError;
  List<String> get equipment => throw _privateConstructorUsedError;

  /// Serializes this Character to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Character
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CharacterCopyWith<Character> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CharacterCopyWith<$Res> {
  factory $CharacterCopyWith(Character value, $Res Function(Character) then) =
      _$CharacterCopyWithImpl<$Res, Character>;
  @useResult
  $Res call({
    String? id,
    String name,
    String race,
    CharacterClass characterClass,
    int level,
    int strength,
    int dexterity,
    int constitution,
    int intelligence,
    int wisdom,
    int charisma,
    List<String> equipment,
  });

  $CharacterClassCopyWith<$Res> get characterClass;
}

/// @nodoc
class _$CharacterCopyWithImpl<$Res, $Val extends Character>
    implements $CharacterCopyWith<$Res> {
  _$CharacterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Character
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? race = null,
    Object? characterClass = null,
    Object? level = null,
    Object? strength = null,
    Object? dexterity = null,
    Object? constitution = null,
    Object? intelligence = null,
    Object? wisdom = null,
    Object? charisma = null,
    Object? equipment = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            race: null == race
                ? _value.race
                : race // ignore: cast_nullable_to_non_nullable
                      as String,
            characterClass: null == characterClass
                ? _value.characterClass
                : characterClass // ignore: cast_nullable_to_non_nullable
                      as CharacterClass,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            strength: null == strength
                ? _value.strength
                : strength // ignore: cast_nullable_to_non_nullable
                      as int,
            dexterity: null == dexterity
                ? _value.dexterity
                : dexterity // ignore: cast_nullable_to_non_nullable
                      as int,
            constitution: null == constitution
                ? _value.constitution
                : constitution // ignore: cast_nullable_to_non_nullable
                      as int,
            intelligence: null == intelligence
                ? _value.intelligence
                : intelligence // ignore: cast_nullable_to_non_nullable
                      as int,
            wisdom: null == wisdom
                ? _value.wisdom
                : wisdom // ignore: cast_nullable_to_non_nullable
                      as int,
            charisma: null == charisma
                ? _value.charisma
                : charisma // ignore: cast_nullable_to_non_nullable
                      as int,
            equipment: null == equipment
                ? _value.equipment
                : equipment // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of Character
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CharacterClassCopyWith<$Res> get characterClass {
    return $CharacterClassCopyWith<$Res>(_value.characterClass, (value) {
      return _then(_value.copyWith(characterClass: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CharacterImplCopyWith<$Res>
    implements $CharacterCopyWith<$Res> {
  factory _$$CharacterImplCopyWith(
    _$CharacterImpl value,
    $Res Function(_$CharacterImpl) then,
  ) = __$$CharacterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String name,
    String race,
    CharacterClass characterClass,
    int level,
    int strength,
    int dexterity,
    int constitution,
    int intelligence,
    int wisdom,
    int charisma,
    List<String> equipment,
  });

  @override
  $CharacterClassCopyWith<$Res> get characterClass;
}

/// @nodoc
class __$$CharacterImplCopyWithImpl<$Res>
    extends _$CharacterCopyWithImpl<$Res, _$CharacterImpl>
    implements _$$CharacterImplCopyWith<$Res> {
  __$$CharacterImplCopyWithImpl(
    _$CharacterImpl _value,
    $Res Function(_$CharacterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Character
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? race = null,
    Object? characterClass = null,
    Object? level = null,
    Object? strength = null,
    Object? dexterity = null,
    Object? constitution = null,
    Object? intelligence = null,
    Object? wisdom = null,
    Object? charisma = null,
    Object? equipment = null,
  }) {
    return _then(
      _$CharacterImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        race: null == race
            ? _value.race
            : race // ignore: cast_nullable_to_non_nullable
                  as String,
        characterClass: null == characterClass
            ? _value.characterClass
            : characterClass // ignore: cast_nullable_to_non_nullable
                  as CharacterClass,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        strength: null == strength
            ? _value.strength
            : strength // ignore: cast_nullable_to_non_nullable
                  as int,
        dexterity: null == dexterity
            ? _value.dexterity
            : dexterity // ignore: cast_nullable_to_non_nullable
                  as int,
        constitution: null == constitution
            ? _value.constitution
            : constitution // ignore: cast_nullable_to_non_nullable
                  as int,
        intelligence: null == intelligence
            ? _value.intelligence
            : intelligence // ignore: cast_nullable_to_non_nullable
                  as int,
        wisdom: null == wisdom
            ? _value.wisdom
            : wisdom // ignore: cast_nullable_to_non_nullable
                  as int,
        charisma: null == charisma
            ? _value.charisma
            : charisma // ignore: cast_nullable_to_non_nullable
                  as int,
        equipment: null == equipment
            ? _value._equipment
            : equipment // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CharacterImpl implements _Character {
  const _$CharacterImpl({
    this.id,
    required this.name,
    required this.race,
    required this.characterClass,
    required this.level,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    final List<String> equipment = const [],
  }) : _equipment = equipment;

  factory _$CharacterImpl.fromJson(Map<String, dynamic> json) =>
      _$$CharacterImplFromJson(json);

  @override
  final String? id;
  @override
  final String name;
  @override
  final String race;
  @override
  final CharacterClass characterClass;
  // Ya contiene hit_dice y profs
  @override
  final int level;
  @override
  final int strength;
  @override
  final int dexterity;
  @override
  final int constitution;
  @override
  final int intelligence;
  @override
  final int wisdom;
  @override
  final int charisma;
  final List<String> _equipment;
  @override
  @JsonKey()
  List<String> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

  @override
  String toString() {
    return 'Character(id: $id, name: $name, race: $race, characterClass: $characterClass, level: $level, strength: $strength, dexterity: $dexterity, constitution: $constitution, intelligence: $intelligence, wisdom: $wisdom, charisma: $charisma, equipment: $equipment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CharacterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.race, race) || other.race == race) &&
            (identical(other.characterClass, characterClass) ||
                other.characterClass == characterClass) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.strength, strength) ||
                other.strength == strength) &&
            (identical(other.dexterity, dexterity) ||
                other.dexterity == dexterity) &&
            (identical(other.constitution, constitution) ||
                other.constitution == constitution) &&
            (identical(other.intelligence, intelligence) ||
                other.intelligence == intelligence) &&
            (identical(other.wisdom, wisdom) || other.wisdom == wisdom) &&
            (identical(other.charisma, charisma) ||
                other.charisma == charisma) &&
            const DeepCollectionEquality().equals(
              other._equipment,
              _equipment,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    race,
    characterClass,
    level,
    strength,
    dexterity,
    constitution,
    intelligence,
    wisdom,
    charisma,
    const DeepCollectionEquality().hash(_equipment),
  );

  /// Create a copy of Character
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CharacterImplCopyWith<_$CharacterImpl> get copyWith =>
      __$$CharacterImplCopyWithImpl<_$CharacterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CharacterImplToJson(this);
  }
}

abstract class _Character implements Character {
  const factory _Character({
    final String? id,
    required final String name,
    required final String race,
    required final CharacterClass characterClass,
    required final int level,
    required final int strength,
    required final int dexterity,
    required final int constitution,
    required final int intelligence,
    required final int wisdom,
    required final int charisma,
    final List<String> equipment,
  }) = _$CharacterImpl;

  factory _Character.fromJson(Map<String, dynamic> json) =
      _$CharacterImpl.fromJson;

  @override
  String? get id;
  @override
  String get name;
  @override
  String get race;
  @override
  CharacterClass get characterClass; // Ya contiene hit_dice y profs
  @override
  int get level;
  @override
  int get strength;
  @override
  int get dexterity;
  @override
  int get constitution;
  @override
  int get intelligence;
  @override
  int get wisdom;
  @override
  int get charisma;
  @override
  List<String> get equipment;

  /// Create a copy of Character
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CharacterImplCopyWith<_$CharacterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
