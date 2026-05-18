// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: _parseInt(json['id']),
      categoryId: _parseInt(json['category_id']),
      name: json['name'] as String,
      buyingPrice: _parseDouble(json['buying_price']),
      sellingPrice: _parseDouble(json['selling_price']),
      stock: _parseInt(json['stock']),
      minStock: json['min_stock'] == null ? 5 : _parseInt(json['min_stock']),
      imagePath: json['image_url'] as String?,
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'name': instance.name,
      'buying_price': instance.buyingPrice,
      'selling_price': instance.sellingPrice,
      'stock': instance.stock,
      'min_stock': instance.minStock,
      'image_url': instance.imagePath,
    };
