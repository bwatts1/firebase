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
  final TextEditingController _categoryFilterController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStockStatus = 'All'; // All, Low Stock, In Stock
  double? _minPrice;
  double? _maxPrice;
  int? _minQuantity;
  int? _maxQuantity;

  Future<void> _createOrUpdate([Product? product]) async {
    final isUpdate = product != null;

    if (isUpdate) {
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
      _quantityController.text = product.quantity.toString();
      _categoryController.text = product.category;
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => SingleChildScrollView(
        child: Padding(
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

                  if (isUpdate) {
                    await _productService.updateProduct(product!.id, name, price, category, quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product updated successfully')),
                    );
                  } else {
                    await _productService.addProduct(name, price, category, quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product added successfully')),
                    );
                  }

                  _nameController.clear();
                  _priceController.clear();
                  _quantityController.clear();
                  _categoryController.clear();
                  Navigator.of(ctx).pop();
                },
                child: Text(isUpdate ? 'Update' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(String id) async {
    await _productService.deleteProduct(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted successfully')),
    );
  }
  Stream<List<Product>> _getFilteredProducts() {
    return _productService.getProductList().map((products) {
      return products.where((p) {
        final matchesName = _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery);

        final matchesCategory = _selectedCategory == 'All' ||
            p.category.toLowerCase() == _selectedCategory.toLowerCase();

        final matchesStockStatus = _selectedStockStatus == 'All' ||
            (_selectedStockStatus == 'Low Stock' && p.quantity < 5) ||
            (_selectedStockStatus == 'In Stock' && p.quantity >= 5);

        final matchesPrice = (_minPrice == null || p.price >= _minPrice!) &&
                             (_maxPrice == null || p.price <= _maxPrice!);

        final matchesQuantity = (_minQuantity == null || p.quantity >= _minQuantity!) &&
                                (_maxQuantity == null || p.quantity <= _maxQuantity!);

        return matchesName && matchesCategory && matchesStockStatus && matchesPrice && matchesQuantity;
      }).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products Manager')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
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
            Wrap(
              spacing: 8.0,
              children: ['All', 'Electronics', 'Clothing', 'Books'].map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : 'All';
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: ['All', 'Low Stock', 'In Stock'].map((status) {
                return ChoiceChip(
                  label: Text(status),
                  selected: _selectedStockStatus == status,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStockStatus = selected ? status : 'All';
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
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
                    setState(() {
                      _searchQuery = '';
                      _selectedCategory = 'All';
                      _selectedStockStatus = 'All';
                      _minPrice = null;
                      _maxPrice = null;
                      _minQuantity = null;
                      _maxQuantity = null;
                    });
                  },
                  child: const Text('Reset Filters'),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                          tileColor: product.quantity < 5 ? Colors.red[50] : null,
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
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}
