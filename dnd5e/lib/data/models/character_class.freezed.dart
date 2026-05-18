// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'character_class.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CharacterClass _$CharacterClassFromJson(Map<String, dynamic> json) {
  return _CharacterClass.fromJson(json);
}

/// @nodoc
mixin _$CharacterClass {
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get hit_dice => throw _privateConstructorUsedError;
  String get prof_saving_throws => throw _privateConstructorUsedError;
  String? get prof_skills => throw _privateConstructorUsedError;
  String? get prof_armor => throw _privateConstructorUsedError;
  String? get prof_weapons => throw _privateConstructorUsedError;
  String? get prof_tools => throw _privateConstructorUsedError;
  String? get equipment => throw _privateConstructorUsedError;
  String? get desc => throw _privateConstructorUsedError;
  String? get table => throw _privateConstructorUsedError;
  String get hp_at_1st_level => throw _privateConstructorUsedError;
  String get hp_at_higher_levels => throw _privateConstructorUsedError;
  String get spellcasting_ability => throw _privateConstructorUsedError;
  String get subtypes_name => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get archetypes =>
      throw _privateConstructorUsedError;

  /// Serializes this CharacterClass to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CharacterClass
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CharacterClassCopyWith<CharacterClass> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CharacterClassCopyWith<$Res> {
  factory $CharacterClassCopyWith(
    CharacterClass value,
    $Res Function(CharacterClass) then,
  ) = _$CharacterClassCopyWithImpl<$Res, CharacterClass>;
  @useResult
  $Res call({
    String name,
    String slug,
    String hit_dice,
    String prof_saving_throws,
    String? prof_skills,
    String? prof_armor,
    String? prof_weapons,
    String? prof_tools,
    String? equipment,
    String? desc,
    String? table,
    String hp_at_1st_level,
    String hp_at_higher_levels,
    String spellcasting_ability,
    String subtypes_name,
    List<Map<String, dynamic>> archetypes,
  });
}

/// @nodoc
class _$CharacterClassCopyWithImpl<$Res, $Val extends CharacterClass>
    implements $CharacterClassCopyWith<$Res> {
  _$CharacterClassCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CharacterClass
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? slug = null,
    Object? hit_dice = null,
    Object? prof_saving_throws = null,
    Object? prof_skills = freezed,
    Object? prof_armor = freezed,
    Object? prof_weapons = freezed,
    Object? prof_tools = freezed,
    Object? equipment = freezed,
    Object? desc = freezed,
    Object? table = freezed,
    Object? hp_at_1st_level = null,
    Object? hp_at_higher_levels = null,
    Object? spellcasting_ability = null,
    Object? subtypes_name = null,
    Object? archetypes = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            hit_dice: null == hit_dice
                ? _value.hit_dice
                : hit_dice // ignore: cast_nullable_to_non_nullable
                      as String,
            prof_saving_throws: null == prof_saving_throws
                ? _value.prof_saving_throws
                : prof_saving_throws // ignore: cast_nullable_to_non_nullable
                      as String,
            prof_skills: freezed == prof_skills
                ? _value.prof_skills
                : prof_skills // ignore: cast_nullable_to_non_nullable
                      as String?,
            prof_armor: freezed == prof_armor
                ? _value.prof_armor
                : prof_armor // ignore: cast_nullable_to_non_nullable
                      as String?,
            prof_weapons: freezed == prof_weapons
                ? _value.prof_weapons
                : prof_weapons // ignore: cast_nullable_to_non_nullable
                      as String?,
            prof_tools: freezed == prof_tools
                ? _value.prof_tools
                : prof_tools // ignore: cast_nullable_to_non_nullable
                      as String?,
            equipment: freezed == equipment
                ? _value.equipment
                : equipment // ignore: cast_nullable_to_non_nullable
                      as String?,
            desc: freezed == desc
                ? _value.desc
                : desc // ignore: cast_nullable_to_non_nullable
                      as String?,
            table: freezed == table
                ? _value.table
                : table // ignore: cast_nullable_to_non_nullable
                      as String?,
            hp_at_1st_level: null == hp_at_1st_level
                ? _value.hp_at_1st_level
                : hp_at_1st_level // ignore: cast_nullable_to_non_nullable
                      as String,
            hp_at_higher_levels: null == hp_at_higher_levels
                ? _value.hp_at_higher_levels
                : hp_at_higher_levels // ignore: cast_nullable_to_non_nullable
                      as String,
            spellcasting_ability: null == spellcasting_ability
                ? _value.spellcasting_ability
                : spellcasting_ability // ignore: cast_nullable_to_non_nullable
                      as String,
            subtypes_name: null == subtypes_name
                ? _value.subtypes_name
                : subtypes_name // ignore: cast_nullable_to_non_nullable
                      as String,
            archetypes: null == archetypes
                ? _value.archetypes
                : archetypes // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CharacterClassImplCopyWith<$Res>
    implements $CharacterClassCopyWith<$Res> {
  factory _$$CharacterClassImplCopyWith(
    _$CharacterClassImpl value,
    $Res Function(_$CharacterClassImpl) then,
  ) = __$$CharacterClassImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String slug,
    String hit_dice,
    String prof_saving_throws,
    String? prof_skills,
    String? prof_armor,
    String? prof_weapons,
    String? prof_tools,
    String? equipment,
    String? desc,
    String? table,
    String hp_at_1st_level,
    String hp_at_higher_levels,
    String spellcasting_ability,
    String subtypes_name,
    List<Map<String, dynamic>> archetypes,
  });
}

/// @nodoc
class __$$CharacterClassImplCopyWithImpl<$Res>
    extends _$CharacterClassCopyWithImpl<$Res, _$CharacterClassImpl>
    implements _$$CharacterClassImplCopyWith<$Res> {
  __$$CharacterClassImplCopyWithImpl(
    _$CharacterClassImpl _value,
    $Res Function(_$CharacterClassImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CharacterClass
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? slug = null,
    Object? hit_dice = null,
    Object? prof_saving_throws = null,
    Object? prof_skills = freezed,
    Object? prof_armor = freezed,
    Object? prof_weapons = freezed,
    Object? prof_tools = freezed,
    Object? equipment = freezed,
    Object? desc = freezed,
    Object? table = freezed,
    Object? hp_at_1st_level = null,
    Object? hp_at_higher_levels = null,
    Object? spellcasting_ability = null,
    Object? subtypes_name = null,
    Object? archetypes = null,
  }) {
    return _then(
      _$CharacterClassImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        hit_dice: null == hit_dice
            ? _value.hit_dice
            : hit_dice // ignore: cast_nullable_to_non_nullable
                  as String,
        prof_saving_throws: null == prof_saving_throws
            ? _value.prof_saving_throws
            : prof_saving_throws // ignore: cast_nullable_to_non_nullable
                  as String,
        prof_skills: freezed == prof_skills
            ? _value.prof_skills
            : prof_skills // ignore: cast_nullable_to_non_nullable
                  as String?,
        prof_armor: freezed == prof_armor
            ? _value.prof_armor
            : prof_armor // ignore: cast_nullable_to_non_nullable
                  as String?,
        prof_weapons: freezed == prof_weapons
            ? _value.prof_weapons
            : prof_weapons // ignore: cast_nullable_to_non_nullable
                  as String?,
        prof_tools: freezed == prof_tools
            ? _value.prof_tools
            : prof_tools // ignore: cast_nullable_to_non_nullable
                  as String?,
        equipment: freezed == equipment
            ? _value.equipment
            : equipment // ignore: cast_nullable_to_non_nullable
                  as String?,
        desc: freezed == desc
            ? _value.desc
            : desc // ignore: cast_nullable_to_non_nullable
                  as String?,
        table: freezed == table
            ? _value.table
            : table // ignore: cast_nullable_to_non_nullable
                  as String?,
        hp_at_1st_level: null == hp_at_1st_level
            ? _value.hp_at_1st_level
            : hp_at_1st_level // ignore: cast_nullable_to_non_nullable
                  as String,
        hp_at_higher_levels: null == hp_at_higher_levels
            ? _value.hp_at_higher_levels
            : hp_at_higher_levels // ignore: cast_nullable_to_non_nullable
                  as String,
        spellcasting_ability: null == spellcasting_ability
            ? _value.spellcasting_ability
            : spellcasting_ability // ignore: cast_nullable_to_non_nullable
                  as String,
        subtypes_name: null == subtypes_name
            ? _value.subtypes_name
            : subtypes_name // ignore: cast_nullable_to_non_nullable
                  as String,
        archetypes: null == archetypes
            ? _value._archetypes
            : archetypes // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CharacterClassImpl implements _CharacterClass {
  const _$CharacterClassImpl({
    required this.name,
    required this.slug,
    required this.hit_dice,
    required this.prof_saving_throws,
    required this.prof_skills,
    required this.prof_armor,
    required this.prof_weapons,
    required this.prof_tools,
    required this.equipment,
    required this.desc,
    required this.table,
    this.hp_at_1st_level = '',
    this.hp_at_higher_levels = '',
    this.spellcasting_ability = '',
    this.subtypes_name = '',
    final List<Map<String, dynamic>> archetypes = const [],
  }) : _archetypes = archetypes;

  factory _$CharacterClassImpl.fromJson(Map<String, dynamic> json) =>
      _$$CharacterClassImplFromJson(json);

  @override
  final String name;
  @override
  final String slug;
  @override
  final String hit_dice;
  @override
  final String prof_saving_throws;
  @override
  final String? prof_skills;
  @override
  final String? prof_armor;
  @override
  final String? prof_weapons;
  @override
  final String? prof_tools;
  @override
  final String? equipment;
  @override
  final String? desc;
  @override
  final String? table;
  @override
  @JsonKey()
  final String hp_at_1st_level;
  @override
  @JsonKey()
  final String hp_at_higher_levels;
  @override
  @JsonKey()
  final String spellcasting_ability;
  @override
  @JsonKey()
  final String subtypes_name;
  final List<Map<String, dynamic>> _archetypes;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get archetypes {
    if (_archetypes is EqualUnmodifiableListView) return _archetypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_archetypes);
  }

  @override
  String toString() {
    return 'CharacterClass(name: $name, slug: $slug, hit_dice: $hit_dice, prof_saving_throws: $prof_saving_throws, prof_skills: $prof_skills, prof_armor: $prof_armor, prof_weapons: $prof_weapons, prof_tools: $prof_tools, equipment: $equipment, desc: $desc, table: $table, hp_at_1st_level: $hp_at_1st_level, hp_at_higher_levels: $hp_at_higher_levels, spellcasting_ability: $spellcasting_ability, subtypes_name: $subtypes_name, archetypes: $archetypes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CharacterClassImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.hit_dice, hit_dice) ||
                other.hit_dice == hit_dice) &&
            (identical(other.prof_saving_throws, prof_saving_throws) ||
                other.prof_saving_throws == prof_saving_throws) &&
            (identical(other.prof_skills, prof_skills) ||
                other.prof_skills == prof_skills) &&
            (identical(other.prof_armor, prof_armor) ||
                other.prof_armor == prof_armor) &&
            (identical(other.prof_weapons, prof_weapons) ||
                other.prof_weapons == prof_weapons) &&
            (identical(other.prof_tools, prof_tools) ||
                other.prof_tools == prof_tools) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment) &&
            (identical(other.desc, desc) || other.desc == desc) &&
            (identical(other.table, table) || other.table == table) &&
            (identical(other.hp_at_1st_level, hp_at_1st_level) ||
                other.hp_at_1st_level == hp_at_1st_level) &&
            (identical(other.hp_at_higher_levels, hp_at_higher_levels) ||
                other.hp_at_higher_levels == hp_at_higher_levels) &&
            (identical(other.spellcasting_ability, spellcasting_ability) ||
                other.spellcasting_ability == spellcasting_ability) &&
            (identical(other.subtypes_name, subtypes_name) ||
                other.subtypes_name == subtypes_name) &&
            const DeepCollectionEquality().equals(
              other._archetypes,
              _archetypes,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    slug,
    hit_dice,
    prof_saving_throws,
    prof_skills,
    prof_armor,
    prof_weapons,
    prof_tools,
    equipment,
    desc,
    table,
    hp_at_1st_level,
    hp_at_higher_levels,
    spellcasting_ability,
    subtypes_name,
    const DeepCollectionEquality().hash(_archetypes),
  );

  /// Create a copy of CharacterClass
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CharacterClassImplCopyWith<_$CharacterClassImpl> get copyWith =>
      __$$CharacterClassImplCopyWithImpl<_$CharacterClassImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CharacterClassImplToJson(this);
  }
}

abstract class _CharacterClass implements CharacterClass {
  const factory _CharacterClass({
    required final String name,
    required final String slug,
    required final String hit_dice,
    required final String prof_saving_throws,
    required final String? prof_skills,
    required final String? prof_armor,
    required final String? prof_weapons,
    required final String? prof_tools,
    required final String? equipment,
    required final String? desc,
    required final String? table,
    final String hp_at_1st_level,
    final String hp_at_higher_levels,
    final String spellcasting_ability,
    final String subtypes_name,
    final List<Map<String, dynamic>> archetypes,
  }) = _$CharacterClassImpl;

  factory _CharacterClass.fromJson(Map<String, dynamic> json) =
      _$CharacterClassImpl.fromJson;

  @override
  String get name;
  @override
  String get slug;
  @override
  String get hit_dice;
  @override
  String get prof_saving_throws;
  @override
  String? get prof_skills;
  @override
  String? get prof_armor;
  @override
  String? get prof_weapons;
  @override
  String? get prof_tools;
  @override
  String? get equipment;
  @override
  String? get desc;
  @override
  String? get table;
  @override
  String get hp_at_1st_level;
  @override
  String get hp_at_higher_levels;
  @override
  String get spellcasting_ability;
  @override
  String get subtypes_name;
  @override
  List<Map<String, dynamic>> get archetypes;

  /// Create a copy of CharacterClass
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CharacterClassImplCopyWith<_$CharacterClassImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
