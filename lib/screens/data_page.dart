import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../services/product.dart';

class DashboardPage extends StatelessWidget {
  final ProductService _productService = ProductService();

  DashboardPage({Key? key}) : super(key: key);

  double _calculateTotalValue(List<Product> products) {
    return products.fold(0, (sum, p) => sum + (p.price * p.quantity));
  }

  int _calculateTotalQuantity(List<Product> products) {
    return products.fold(0, (sum, p) => sum + p.quantity);
  }

  List<Product> _getOutOfStock(List<Product> products) {
    return products.where((p) => p.quantity == 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productService.getProductList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          final products = snapshot.data!;
          final totalItems = products.length;
          final totalQuantity = _calculateTotalQuantity(products);
          final totalValue = _calculateTotalValue(products);
          final outOfStock = _getOutOfStock(products);

          return RefreshIndicator(
            onRefresh: () async {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Card(
                    color: Colors.blue[50],
                    child: ListTile(
                      leading: const Icon(Icons.inventory, size: 40),
                      title: const Text('Total Unique Items'),
                      trailing: Text(
                        '$totalItems',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Card(
                    color: Colors.orange[50],
                    child: ListTile(
                      leading: const Icon(Icons.add_shopping_cart, size: 40),
                      title: const Text('Total Quantity in Stock'),
                      trailing: Text(
                        '$totalQuantity',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Card(
                    color: Colors.green[50],
                    child: ListTile(
                      leading: const Icon(Icons.attach_money, size: 40),
                      title: const Text('Total Inventory Value'),
                      trailing: Text(
                        '\$${totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Out-of-Stock Items:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (outOfStock.isEmpty)
                    const Text('✅ All items are in stock')
                  else
                    Column(
                      children: outOfStock.map((product) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(product.name),
                            subtitle: Text('Category: ${product.category}'),
                            trailing:
                                const Icon(Icons.error, color: Colors.red),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
