class ProductEntity {
  final String id;
  final String title;
  final String description;
  final String price;
  final String imageUrl;
  final String supplierId;
  final String supplierName;
  final DateTime createdAt;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.supplierId,
    required this.supplierName,
    required this.createdAt,
  });

  ProductEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? price,
    String? imageUrl,
    String? supplierId,
    String? supplierName,
    DateTime? createdAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ProductEntity(id: $id, title: $title, price: $price)';
}
