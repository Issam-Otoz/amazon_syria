import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:amazon_syria/features/products/domain/entities/product_entity.dart';
import 'package:amazon_syria/features/products/domain/repositories/product_repository.dart';
import 'package:amazon_syria/features/products/data/models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('products');

  @override
  Future<List<ProductEntity>> getProducts({
    String? lastDocId,
    int limit = 10,
    String? searchQuery,
    String sortBy = 'createdAt',
    bool descending = true,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    } else {
      query = query.orderBy(sortBy, descending: descending);
    }

    if (lastDocId != null) {
      final lastDoc = await _collection.doc(lastDocId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return List<ProductEntity>.from(
      snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)),
    );
  }

  @override
  Future<ProductEntity> getProductById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw Exception('المنتج غير موجود');
    }
    return ProductModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    await _collection.doc(product.id).set(model.toMap());
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _collection.doc(productId).delete();
  }

  @override
  Future<List<ProductEntity>> getSupplierProducts(String supplierId) async {
    final snapshot = await _collection
        .where('supplierId', isEqualTo: supplierId)
        .orderBy('createdAt', descending: true)
        .get();

    return List<ProductEntity>.from(
      snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)),
    );
  }
}
