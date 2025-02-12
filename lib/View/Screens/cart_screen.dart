import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopchecker/Model/Product.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _selectAll = false;
  List<bool> _selectedItems = [];

  void _initializeSelection(int itemCount) {
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
          if (cart.cartList[i].containsKey('count')) {
            cart.removeFromCart(i, true);
          }

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
              child: Text(
                'Закрыть',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  late Future<List> _recomendCartFuture;
  late Cart cart;
  @override
  void initState() {
    super.initState();

    cart = ref.read(cartModelProvider);
    _recomendCartFuture = cart.setRecomendCart();
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = cart.cartList.length;
    final totalPrice = cart.totalPrice;
    final discount = cart.totalDiscount;
    _initializeSelection(totalItems);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: const Text('Корзина')),
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
            if (index == 0) {
              Navigator.pop(context);
            } else if (index == 2) {
              Navigator.pushReplacementNamed(
                context,
                '/settings',
              );
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
              icon: Icon(Icons.settings_outlined),
              label: "Настройки",
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
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.onSecondary)),
                    onPressed: _onDeleteSelected,
                    child: Text(
                      'Удалить выбранные',
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
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedItems[index] =
                                                !_selectedItems[index];
                                          });
                                        },
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
                                              fit: BoxFit.contain,
                                              width: 120,
                                              height: 120,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                } else {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
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
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object error,
                                                      StackTrace? stackTrace) {
                                                return const Center(
                                                    child: Icon(Icons.error));
                                              },
                                            ),
                                          ],
                                        ),
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
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Цена: ${product['price'].toString()} руб.',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                            ),
                                            const SizedBox(height: 4),
                                            if (product.containsKey('count'))
                                              Text(
                                                'Колличество: ${product['count'].toString()} шт ',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary),
                                              ),
                                            const SizedBox(height: 4),
                                            if (product.containsKey('count'))
                                              Text(
                                                'Итого: ${((product['price'] * product['count'])).toStringAsFixed(2)} руб.',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary),
                                              ),
                                            Text(
                                              'Магазин: ${product['store_name'].toString()}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                            ),
                                            const SizedBox(height: 4),
                                            Center(
                                              child: Row(
                                                children: [
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        cart.removeFromCart(
                                                            index, true);
                                                      });
                                                    },
                                                    child: Text(
                                                      "-",
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        cart.addToCart(product);
                                                      });
                                                    },
                                                    child: Text(
                                                      "+",
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: Text(
                                      "Похожие товары",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    ),
                                  ),
                                  FutureBuilder<List>(
                                    future: _recomendCartFuture,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<List> snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ));
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Ошибка: ${snapshot.error}'));
                                      } else if (snapshot.hasData) {
                                        List data = snapshot.data!;

                                        try {
                                          if (data[index]
                                              .containsKey('cluster')) {
                                            data = data[index]['cluster'];
                                          }
                                        } catch (e) {
                                          if (e.toString().contains(
                                                  'RangeError (index)') ||
                                              e
                                                  .toString()
                                                  .contains('Invalid value')) {
                                            data = [];
                                            return Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                child: Text(
                                                  'Чтобы получить похожие товары, для этого товара, перезагрузите корзину',
                                                  softWrap: true,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            );
                                          } else {
                                            print(e);
                                          }
                                        }
                                        if (data.isEmpty) {
                                          return Center(
                                            child: Text(
                                              'Для данного товара не удалось найти похожих товаров',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  fontSize: 16),
                                            ),
                                          );
                                        }
                                        return SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 250,
                                          child: ListView.builder(
                                            itemCount: data.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              final recInfo = data[index];

                                              return InkWell(
                                                  onTap: () => setState(() {
                                                        (cart.addToCart(
                                                            recInfo));
                                                        _recomendCartFuture = cart
                                                            .setRecomendCart();
                                                      }),
                                                  child: Card(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: Column(
                                                      children: [
                                                        Image.network(
                                                          recInfo['image_url'],
                                                          fit: BoxFit.contain,
                                                          width: 120,
                                                          height: 120,
                                                          loadingBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Widget child,
                                                                  ImageChunkEvent?
                                                                      loadingProgress) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            } else {
                                                              return Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  color: Theme.of(
                                                                          context)
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
                                                          errorBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Object error,
                                                                  StackTrace?
                                                                      stackTrace) {
                                                            return const Center(
                                                                child: Icon(Icons
                                                                    .error));
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8.0),
                                                          child: SizedBox(
                                                            height: 70,
                                                            width: 130,
                                                            child: Text(
                                                              recInfo['name'],
                                                              softWrap: true,
                                                              maxLines: 3,
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onPrimary),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 1,
                                                        ),
                                                        Text(
                                                          '${recInfo['price'].toString()} руб.',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary),
                                                        ),
                                                        const SizedBox(
                                                          height: 1,
                                                        ),
                                                        Text(
                                                          '${recInfo['store_name']}',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary),
                                                        ),
                                                      ],
                                                    ),
                                                  ));
                                            },
                                          ),
                                        );
                                      } else {
                                        return Center(
                                            child: Text('Нет данных'));
                                      }
                                    },
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
                color: Theme.of(context).colorScheme.surface,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 3.0, horizontal: 16.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 16,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Товары ($totalItems)'),
                          const SizedBox(height: 8),
                          Text(
                              'Общая цена: ${totalPrice.toStringAsFixed(2)} руб.'),
                          const SizedBox(height: 8),
                          Text('Скидка: ${discount.toStringAsFixed(2)} руб.'),
                        ],
                      ),
                    ),
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
