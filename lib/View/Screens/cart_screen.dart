import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopcheckerpro/Model/Product.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _selectAll = false;
  List<bool> _selectedItems = [];

  void _initializeSelection(int itemCount) {
    // Инициализируем _selectedItems с учетом текущего количества элементов
    if (_selectedItems.length != itemCount) {
      _selectedItems = List<bool>.generate(itemCount, (index) => false);
    }
  }

  void _onSelectAllChanged(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      _selectedItems = List<bool>.filled(_selectedItems.length, _selectAll);
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
        }
      }
      _selectedItems = List<bool>.filled(cart.cartList.length, false);
      _selectAll = false;
    });
  }

  void _showFullText(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            text,
            softWrap: true,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartModelProvider);
    final totalItems = cart.cartList.length;
    final totalPrice = cart.totalPrice;
    final discount = cart.totalDiscount;

    // Инициализация выбранных элементов в зависимости от текущего количества товаров
    _initializeSelection(totalItems);

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
                    shape: const CircleBorder(),
                    activeColor: (Theme.of(context).colorScheme.secondary),
                    value: _selectAll,
                    onChanged: _onSelectAllChanged,
                  ),
                  const Text('Выбрать все'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _onDeleteSelected,
                    child: Text(
                      'Удалить выбранные',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
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
                  child: totalItems != 0
                      ? ListView.builder(
                          itemCount: totalItems,
                          itemBuilder: (context, index) {
                            final product = cart.cartList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Checkbox(
                                    shape: const CircleBorder(),
                                    activeColor: (Theme.of(context)
                                        .colorScheme
                                        .secondary),
                                    value: _selectedItems[index],
                                    onChanged: (value) =>
                                        _onItemChanged(index, value),
                                  ),
                                  Image.network(
                                    product['imageUrl'],
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                        .expectedTotalBytes!)
                                                : null,
                                          ),
                                        );
                                      }
                                    },
                                    errorBuilder: (BuildContext context,
                                        Object error, StackTrace? stackTrace) {
                                      return const Center(
                                          child: Icon(Icons.error));
                                    },
                                  ), //Text(product['name']),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _showFullText(
                                              context, product['name']),
                                          child: Text(
                                            product['name'],
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Цена: ${product['price']} руб.',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Итого: ${product['price']} руб.',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            'Вы еще не добавили ничего в корзину!\nНажмите по товару один раз, чтобы добавить его в корзину.\nДвойное нажатие удаляет товар из корзины.',
                            textAlign: TextAlign.center,
                          ),
                        )),
              const SizedBox(height: 5),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 3.0, horizontal: 16.0),
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
