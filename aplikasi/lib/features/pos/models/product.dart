class Product {
  final int id;
  final int categoryId;
  final String name;
  final double buyingPrice;
  final double sellingPrice;
  final int stock;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        categoryId: int.parse(json['category_id'].toString()),
        name: json['name'],
        buyingPrice: double.parse(json['buying_price'].toString()),
        sellingPrice: double.parse(json['selling_price'].toString()),
        stock: int.parse(json['stock'].toString()),
      );

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        categoryId: map['category_id'],
        name: map['name'],
        buyingPrice: map['buying_price'],
        sellingPrice: map['selling_price'],
        stock: map['stock'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
        'buying_price': buyingPrice,
        'selling_price': sellingPrice,
        'stock': stock,
      };
}
