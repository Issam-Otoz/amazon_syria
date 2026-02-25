import 'package:flutter/foundation.dart';

import 'package:amazon_syria/features/products/domain/entities/product_entity.dart';
import 'package:amazon_syria/features/products/domain/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  ProductProvider(this._repository);

  List<ProductEntity> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  String _searchQuery = '';
  String _sortBy = 'createdAt';
  bool _sortDescending = true;

  List<ProductEntity> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get sortDescending => _sortDescending;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    _products = [];
    _hasMore = true;
    notifyListeners();

    try {
      final result = await _repository.getProducts(
        limit: 10,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        descending: _sortDescending,
      );
      _products = result;
      _hasMore = result.length >= 10;
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل المنتجات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore || _products.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final lastDocId = _products.last.id;
      final result = await _repository.getProducts(
        lastDocId: lastDocId,
        limit: 10,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        descending: _sortDescending,
      );
      _products.addAll(result);
      _hasMore = result.length >= 10;
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل المزيد';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    await loadProducts();
  }

  Future<void> setSortBy(String field, bool descending) async {
    _sortBy = field;
    _sortDescending = descending;
    await loadProducts();
  }

  Future<void> addProduct(ProductEntity product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.addProduct(product);
      _products.insert(0, product);
    } catch (e) {
      _error = 'حدث خطأ أثناء إضافة المنتج';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
    } catch (e) {
      _error = 'حدث خطأ أثناء حذف المنتج';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ProductEntity> getProductById(String id) async {
    return await _repository.getProductById(id);
  }

  Future<List<ProductEntity>> getSupplierProducts(String supplierId) async {
    try {
      return await _repository.getSupplierProducts(supplierId);
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل منتجات المورّد';
      notifyListeners();
      return [];
    }
  }

  Future<void> refreshProducts() async {
    _searchQuery = '';
    await loadProducts();
  }
}
