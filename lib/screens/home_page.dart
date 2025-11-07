import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../services/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _minQuantityController = TextEditingController();
  final TextEditingController _maxQuantityController = TextEditingController();

  String _searchQuery = '';
  String _categoryQuery = '';
  double? _minPrice;
  double? _maxPrice;
  int? _minQuantity;
  int? _maxQuantity;

  // Create or Update Product
  Future<void> _createOrUpdate([Product? product]) async {
    String action = product == null ? 'create' : 'update';
    if (product != null) {
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
      _quantityController.text = product.quantity.toString();
      _categoryController.text = product.category;
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final price = double.tryParse(_priceController.text) ?? 0;
                final quantity = int.tryParse(_quantityController.text) ?? 0;
                final category = _categoryController.text.trim();

                if (name.isEmpty) return;

                if (action == 'create') {
                  await _productService.addProduct(name, price, category, quantity);
                } else {
                  await _productService.updateProduct(product!.id, name, price, category, quantity);
                }

                _nameController.clear();
                _priceController.clear();
                _quantityController.clear();
                _categoryController.clear();
                Navigator.of(ctx).pop();
              },
              child: Text(action == 'create' ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  // Delete product
  Future<void> _deleteProduct(String id) async {
    await _productService.deleteProduct(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted successfully')),
    );
  }

  // Filtered Stream
  Stream<List<Product>> _getFilteredProducts() {
    Stream<List<Product>> stream = _productService.getProductList();

    // Apply search by name
    if (_searchQuery.isNotEmpty) {
      stream = _productService.searchProductsByName(_searchQuery);
    }

    // Apply category filter
    if (_categoryQuery.isNotEmpty) {
      stream = _productService.searchProductsByCategory(_categoryQuery);
    }

    // Apply price filter
    if (_minPrice != null || _maxPrice != null) {
      stream = _productService.filterByPrice(_minPrice, _maxPrice);
    }

    // Apply quantity filter
    if (_minQuantity != null || _maxQuantity != null) {
      stream = _productService.filterByQuantity(_minQuantity, _maxQuantity);
    }

    return stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products Manager')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Search
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.trim().toLowerCase());
              },
            ),
            const SizedBox(height: 10),
            // Filters: price, quantity, category
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    decoration: const InputDecoration(labelText: 'Min Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    decoration: const InputDecoration(labelText: 'Max Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minQuantityController,
                    decoration: const InputDecoration(labelText: 'Min Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maxQuantityController,
                    decoration: const InputDecoration(labelText: 'Max Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category filter',
                prefixIcon: Icon(Icons.category),
              ),
              onChanged: (value) {
                setState(() => _categoryQuery = value.trim().toLowerCase());
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _minPrice = double.tryParse(_minPriceController.text);
                      _maxPrice = double.tryParse(_maxPriceController.text);
                      _minQuantity = int.tryParse(_minQuantityController.text);
                      _maxQuantity = int.tryParse(_maxQuantityController.text);
                    });
                  },
                  child: const Text('Apply Filters'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _searchController.clear();
                    _minPriceController.clear();
                    _maxPriceController.clear();
                    _minQuantityController.clear();
                    _maxQuantityController.clear();
                    _categoryController.clear();
                    setState(() {
                      _searchQuery = '';
                      _minPrice = null;
                      _maxPrice = null;
                      _minQuantity = null;
                      _maxQuantity = null;
                      _categoryQuery = '';
                    });
                  },
                  child: const Text('Reset Filters'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Product list
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: _getFilteredProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }

                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                              '\$${product.price.toStringAsFixed(2)} | Qty: ${product.quantity} | Cat: ${product.category}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _createOrUpdate(product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteProduct(product.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
