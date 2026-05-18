import 'package:freezed_annotation/freezed_annotation.dart';
import 'product.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
class CartItem with _$CartItem {
  const CartItem._(); // For custom getters

  const factory CartItem({
    required Product product,
    @Default(1) int quantity,
  }) = _CartItem;

  double get subtotal => product.sellingPrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
}
