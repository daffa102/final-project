import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

int _parseInt(dynamic value) => value is int ? value : int.tryParse(value.toString()) ?? 0;

// ignore_for_file: invalid_annotation_target
@freezed
class Category with _$Category {
  const factory Category({
    @JsonKey(fromJson: _parseInt) required int id,
    required String name,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}
