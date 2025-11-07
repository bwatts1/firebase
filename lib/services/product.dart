class Product {
  String id;
  String name;
  double price;
  String category; 
  double quantity; 

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'category': category,
    };
  }

  factory Product.fromDoc(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? 'misc',
      quantity: (data['quantity'] ?? 1).toDouble(),
    );
  }
}
