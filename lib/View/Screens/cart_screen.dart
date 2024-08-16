import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopcheckerpro/Model/Product.dart';
//import 'package:shopcheckerpro/ViewModel/Products_ViewModel.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _selectAll = false;
  List<bool> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = ref.read(cartModelProvider);
      _selectedItems =
          List<bool>.generate(cart.cartList.length, (index) => false);
    });
  }

  void _onSelectAllChanged(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      final cart = ref.read(cartModelProvider);
      _selectedItems = List<bool>.filled(cart.cartList.length, _selectAll);
    });
  }

  void _onItemChanged(int index, bool? value) {
    setState(() {
      _selectedItems[index] = value ?? false;
      _selectAll = _selectedItems.every((item) => item);
    });
  }

  void _onDeleteSelected() {
    final cart = ref.read(cartModelProvider);
    setState(() {
      for (int i = _selectedItems.length - 1; i >= 0; i--) {
        if (_selectedItems[i]) {
          cart.removeFromCart(i);
          _selectedItems.removeAt(i);
        }
      }
      _selectAll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartModelProvider);
    final totalItems = cart.cartList.length;
    final totalPrice = cart.totalPrice;
    final discount = cart.totalDiscount;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Корзина'),
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
            if (index == 0) {
              Navigator.pop(context);
            }
          },
          currentIndex: 1,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              label: "Товары",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: "Корзина",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              label: "Профиль",
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _selectAll,
                    onChanged: _onSelectAllChanged,
                  ),
                  const Text('Выбрать все'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _onDeleteSelected,
                    child: const Text('Удалить выбранные'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Содержимое корзины',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: totalItems,
                  itemBuilder: (context, index) {
                    final product = cart.cartList[index];
                    final quantity = product['quantity'];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: Checkbox(
                          value: _selectedItems[index],
                          onChanged: (value) => _onItemChanged(index, value),
                        ),
                        title: Text(product['name']),
                        subtitle: Text(
                          'Цена: ${product['price']} руб. Количество: $quantity',
                        ),
                        trailing: Text(
                          'Итого: ${(product['price'] * quantity).toStringAsFixed(2)} руб.',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Товары ($totalItems)'),
                      const SizedBox(height: 8),
                      Text('Общая цена: ${totalPrice.toStringAsFixed(2)} руб.'),
                      const SizedBox(height: 8),
                      Text('Скидка: ${discount.toStringAsFixed(2)} руб.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
