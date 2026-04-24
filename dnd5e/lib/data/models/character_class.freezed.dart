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
  String toString() {
    return 'CharacterClass(name: $name, slug: $slug, hit_dice: $hit_dice, prof_saving_throws: $prof_saving_throws)';
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
                other.prof_saving_throws == prof_saving_throws));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, slug, hit_dice, prof_saving_throws);

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

  /// Create a copy of CharacterClass
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CharacterClassImplCopyWith<_$CharacterClassImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
