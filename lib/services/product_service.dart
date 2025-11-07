import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/product.dart';

class ProductService {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(String name, double price, String category, int quantity) async {
    await _products.add({
      'name': name,
      'name_lower': name.toLowerCase(),
      'category': category,
      'category_lower': category.toLowerCase(),
      'price': price,
      'quantity': quantity,
    });
  }

  Stream<List<Product>> getProductList() {
    return _products.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromDoc(doc.id, doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> updateProduct(String id, String name, double price, String category, int quantity) async {
    await _products.doc(id).update({
      'name': name,
      'name_lower': name.toLowerCase(),
      'category': category,
      'category_lower': category.toLowerCase(),
      'price': price,
      'quantity': quantity,
    });
  }

  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
  }

  Stream<List<Product>> searchProductsByName(String query) {
    if (query.isEmpty) return getProductList();
    final q = query.toLowerCase();
    return _products
        .where('name_lower', isGreaterThanOrEqualTo: q)
        .where('name_lower', isLessThanOrEqualTo: '$q\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Product.fromDoc(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Product>> searchProductsByCategory(String query) {
    if (query.isEmpty) return getProductList();
    final q = query.toLowerCase();
    return _products
        .where('category_lower', isGreaterThanOrEqualTo: q)
        .where('category_lower', isLessThanOrEqualTo: '$q\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Product.fromDoc(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Product>> filterByPrice(double? min, double? max) {
    Query query = _products;
    if (min != null) query = query.where('price', isGreaterThanOrEqualTo: min);
    if (max != null) query = query.where('price', isLessThanOrEqualTo: max);
    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => Product.fromDoc(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Product>> filterByQuantity(int? min, int? max) {
    Query query = _products;
    if (min != null) query = query.where('quantity', isGreaterThanOrEqualTo: min);
    if (max != null) query = query.where('quantity', isLessThanOrEqualTo: max);
    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => Product.fromDoc(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }
}
