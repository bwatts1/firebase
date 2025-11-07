import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/product.dart';

class ProductService {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  // Create
  Future<void> addProduct(String name, double price) async {
    await _products.add({'name': name, 'price': price});
  }

  // Read (all)
  Stream<QuerySnapshot> getProducts() {
    return _products.snapshots();
  }

  // Update
  Future<void> updateProduct(String id, String name, double price) async {
    await _products.doc(id).update({'name': name, 'price': price});
  }

  // Delete
  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
  }

  // Search by name (case-insensitive)
  Stream<QuerySnapshot> searchProducts(String query) {
    if (query.isEmpty) return getProducts();
    final q = query.toLowerCase();
    return _products
        .where('name', isGreaterThanOrEqualTo: q)
        .where('name', isLessThanOrEqualTo: '$q\uf8ff')
        .snapshots();
  }

  // Filter by price range
  Stream<QuerySnapshot> filterByPrice(double? min, double? max) {
    Query query = _products;
    if (min != null) query = query.where('price', isGreaterThanOrEqualTo: min);
    if (max != null) query = query.where('price', isLessThanOrEqualTo: max);
    return query.snapshots();
  }
}
