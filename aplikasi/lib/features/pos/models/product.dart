import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

int _parseInt(dynamic value) => value is int ? value : int.tryParse(value.toString()) ?? 0;
double _parseDouble(dynamic value) => value is double ? value : double.tryParse(value.toString()) ?? 0.0;

// ignore_for_file: invalid_annotation_target
@freezed
class Product with _$Product {
  const factory Product({
    @JsonKey(fromJson: _parseInt) required int id,
    @JsonKey(name: 'category_id', fromJson: _parseInt) required int categoryId,
    required String name,
    @JsonKey(name: 'buying_price', fromJson: _parseDouble) required double buyingPrice,
    @JsonKey(name: 'selling_price', fromJson: _parseDouble) required double sellingPrice,
    @JsonKey(fromJson: _parseInt) required int stock,
    @Default(5) @JsonKey(name: 'min_stock', fromJson: _parseInt) int minStock,
    @JsonKey(name: 'image_url') String? imagePath,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}
