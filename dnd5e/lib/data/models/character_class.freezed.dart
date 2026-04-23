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
  @JsonKey(name: 'hp_die')
  int get hpDie => throw _privateConstructorUsedError;

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
  $Res call({String name, String slug, @JsonKey(name: 'hp_die') int hpDie});
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
  $Res call({Object? name = null, Object? slug = null, Object? hpDie = null}) {
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
            hpDie: null == hpDie
                ? _value.hpDie
                : hpDie // ignore: cast_nullable_to_non_nullable
                      as int,
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
  $Res call({String name, String slug, @JsonKey(name: 'hp_die') int hpDie});
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
  $Res call({Object? name = null, Object? slug = null, Object? hpDie = null}) {
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
        hpDie: null == hpDie
            ? _value.hpDie
            : hpDie // ignore: cast_nullable_to_non_nullable
                  as int,
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
    @JsonKey(name: 'hp_die') required this.hpDie,
  });

  factory _$CharacterClassImpl.fromJson(Map<String, dynamic> json) =>
      _$$CharacterClassImplFromJson(json);

  @override
  final String name;
  @override
  final String slug;
  @override
  @JsonKey(name: 'hp_die')
  final int hpDie;

  @override
  String toString() {
    return 'CharacterClass(name: $name, slug: $slug, hpDie: $hpDie)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CharacterClassImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.hpDie, hpDie) || other.hpDie == hpDie));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, slug, hpDie);

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
    @JsonKey(name: 'hp_die') required final int hpDie,
  }) = _$CharacterClassImpl;

  factory _CharacterClass.fromJson(Map<String, dynamic> json) =
      _$CharacterClassImpl.fromJson;

  @override
  String get name;
  @override
  String get slug;
  @override
  @JsonKey(name: 'hp_die')
  int get hpDie;

  /// Create a copy of CharacterClass
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CharacterClassImplCopyWith<_$CharacterClassImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
