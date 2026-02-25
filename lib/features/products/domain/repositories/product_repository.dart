import 'package:amazon_syria/features/products/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({
    String? lastDocId,
    int limit = 10,
    String? searchQuery,
    String sortBy = 'createdAt',
    bool descending = true,
  });

  Future<ProductEntity> getProductById(String id);

  Future<void> addProduct(ProductEntity product);

  Future<void> deleteProduct(String productId);

  Future<List<ProductEntity>> getSupplierProducts(String supplierId);
}
