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
  String get slug =>
      throw _privateConstructorUsedError; // Usamos hit_dice porque así lo estás llamando en tu pantalla de selección
  String get hit_dice => throw _privateConstructorUsedError;
  String get prof_saving_throws => throw _privateConstructorUsedError;
  String? get prof_skills => throw _privateConstructorUsedError;
  String? get armor_proficiencies => throw _privateConstructorUsedError;
  String? get weapon_proficiencies => throw _privateConstructorUsedError;
  String? get tool_proficiencies => throw _privateConstructorUsedError;
  String? get equipment => throw _privateConstructorUsedError;

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
    String? armor_proficiencies,
    String? weapon_proficiencies,
    String? tool_proficiencies,
    String? equipment,
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
    Object? armor_proficiencies = freezed,
    Object? weapon_proficiencies = freezed,
    Object? tool_proficiencies = freezed,
    Object? equipment = freezed,
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
            armor_proficiencies: freezed == armor_proficiencies
                ? _value.armor_proficiencies
                : armor_proficiencies // ignore: cast_nullable_to_non_nullable
                      as String?,
            weapon_proficiencies: freezed == weapon_proficiencies
                ? _value.weapon_proficiencies
                : weapon_proficiencies // ignore: cast_nullable_to_non_nullable
                      as String?,
            tool_proficiencies: freezed == tool_proficiencies
                ? _value.tool_proficiencies
                : tool_proficiencies // ignore: cast_nullable_to_non_nullable
                      as String?,
            equipment: freezed == equipment
                ? _value.equipment
                : equipment // ignore: cast_nullable_to_non_nullable
                      as String?,
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
    String? armor_proficiencies,
    String? weapon_proficiencies,
    String? tool_proficiencies,
    String? equipment,
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
    Object? armor_proficiencies = freezed,
    Object? weapon_proficiencies = freezed,
    Object? tool_proficiencies = freezed,
    Object? equipment = freezed,
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
        armor_proficiencies: freezed == armor_proficiencies
            ? _value.armor_proficiencies
            : armor_proficiencies // ignore: cast_nullable_to_non_nullable
                  as String?,
        weapon_proficiencies: freezed == weapon_proficiencies
            ? _value.weapon_proficiencies
            : weapon_proficiencies // ignore: cast_nullable_to_non_nullable
                  as String?,
        tool_proficiencies: freezed == tool_proficiencies
            ? _value.tool_proficiencies
            : tool_proficiencies // ignore: cast_nullable_to_non_nullable
                  as String?,
        equipment: freezed == equipment
            ? _value.equipment
            : equipment // ignore: cast_nullable_to_non_nullable
                  as String?,
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
    required this.armor_proficiencies,
    required this.weapon_proficiencies,
    required this.tool_proficiencies,
    required this.equipment,
  });

  factory _$CharacterClassImpl.fromJson(Map<String, dynamic> json) =>
      _$$CharacterClassImplFromJson(json);

  @override
  final String name;
  @override
  final String slug;
  // Usamos hit_dice porque así lo estás llamando en tu pantalla de selección
  @override
  final String hit_dice;
  @override
  final String prof_saving_throws;
  @override
  final String? prof_skills;
  @override
  final String? armor_proficiencies;
  @override
  final String? weapon_proficiencies;
  @override
  final String? tool_proficiencies;
  @override
  final String? equipment;

  @override
  String toString() {
    return 'CharacterClass(name: $name, slug: $slug, hit_dice: $hit_dice, prof_saving_throws: $prof_saving_throws, prof_skills: $prof_skills, armor_proficiencies: $armor_proficiencies, weapon_proficiencies: $weapon_proficiencies, tool_proficiencies: $tool_proficiencies, equipment: $equipment)';
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
            (identical(other.armor_proficiencies, armor_proficiencies) ||
                other.armor_proficiencies == armor_proficiencies) &&
            (identical(other.weapon_proficiencies, weapon_proficiencies) ||
                other.weapon_proficiencies == weapon_proficiencies) &&
            (identical(other.tool_proficiencies, tool_proficiencies) ||
                other.tool_proficiencies == tool_proficiencies) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment));
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
    armor_proficiencies,
    weapon_proficiencies,
    tool_proficiencies,
    equipment,
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
    required final String? armor_proficiencies,
    required final String? weapon_proficiencies,
    required final String? tool_proficiencies,
    required final String? equipment,
  }) = _$CharacterClassImpl;

  factory _CharacterClass.fromJson(Map<String, dynamic> json) =
      _$CharacterClassImpl.fromJson;

  @override
  String get name;
  @override
  String get slug; // Usamos hit_dice porque así lo estás llamando en tu pantalla de selección
  @override
  String get hit_dice;
  @override
  String get prof_saving_throws;
  @override
  String? get prof_skills;
  @override
  String? get armor_proficiencies;
  @override
  String? get weapon_proficiencies;
  @override
  String? get tool_proficiencies;
  @override
  String? get equipment;

  /// Create a copy of CharacterClass
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CharacterClassImplCopyWith<_$CharacterClassImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
