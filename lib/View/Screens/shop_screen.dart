import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopchecker/Model/Product.dart';
import 'package:shopchecker/ViewModel/products_ViewModel.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Shop extends ConsumerStatefulWidget {
  const Shop({Key? key}) : super(key: key);

  @override
  _ShopState createState() => _ShopState();
}

class _ShopState extends ConsumerState<Shop> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopViewModelProvider)
          .loadProducts(_searchController.text, context);
      ref.read(cartModelProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    int debounceDuration = value.length <= 3 ? 1000 : 500;

    _debounce = Timer(Duration(milliseconds: debounceDuration), () {
      ref.read(shopViewModelProvider).loadProducts(value, context);
    });
  }

  Widget buildGrid(int crossAxisCount, double itemHeightFactor) {
    final viewModel = ref.watch(shopViewModelProvider);
    final cartModel = ref.watch(cartModelProvider);
    final cartList = cartModel.cartList;
    if (viewModel.filteredProducts.isEmpty) {
      return const Center(
        child: Text('Ничего не найдено'),
      );
    } else {
      return MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        itemCount: viewModel.filteredProducts.length,
        itemBuilder: (BuildContext context, int index) {
          final product = viewModel.filteredProducts[index];
          final productMap = {
            'name': product.name,
            'price': product.price,
            'oldPrice': product.oldPrice,
            'imageUrl': product.imageUrl,
            'store_name': product.storeName,
          };

          return AnimatedProductCard(
            product: product,
            cartList: cartList,
            productMap: productMap,
            itemHeightFactor: itemHeightFactor,
            onTap: () {
              ref.read(cartModelProvider).addToCart(productMap);
              viewModel.handleTapOutside(context);
            },
            onDoubleTap: () {
              final Cart provider = ref.read(cartModelProvider);
              final List<Map<String, dynamic>> cart = provider.checkCart();
              for (int i = 0; i < cart.length; i++) {
                if (cart[i]['name'] == product.name &&
                    cart[i]['price'] == product.price) {
                  provider.removeFromCart(i);
                  viewModel.handleTapOutside(context);
                  break;
                }
              }
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(shopViewModelProvider);
    return GestureDetector(
      onTap: () => viewModel.handleTapOutside(context),
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: AppBar(
              actions: [
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextField(
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    controller: _searchController,
                    focusNode: viewModel.searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Искать товары',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onPrimary,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 1.0,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: _onSearchChanged,
                  ),
                ),
                SizedBox(
                  height: 55,
                  width: 50,
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.filter_list_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onSelected: (String result) {
                      if (result.startsWith('Store:')) {
                        ref
                            .read(shopViewModelProvider)
                            .updateStoreFilter(result.substring(6));
                      } else if (result.startsWith('Sort:')) {
                        ref
                            .read(shopViewModelProvider)
                            .updateSortFilter(result.substring(5));
                      }
                    },
                    itemBuilder: (BuildContext context) => <String>[
                      'Store:Все магазины',
                      'Store:Магнит',
                      'Store:Перекресток',
                      'Store:Ашан',
                      'Sort:Без сортировки',
                      'Sort:По возрастанию',
                      'Sort:По убыванию',
                    ].map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            onTap: (int index) {
              if (index == 1) {
                Navigator.pushNamed(context, '/cart');
              } else if (index == 2) {
                Navigator.pushNamed(context, '/settings');
              }
            },
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
          body: Column(
            children: [
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return buildGrid(2, 6);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedProductCard extends StatefulWidget {
  final Product product;
  final List<Map<String, dynamic>> cartList;
  final Map<String, dynamic> productMap;
  final double itemHeightFactor;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  const AnimatedProductCard({
    Key? key,
    required this.product,
    required this.cartList,
    required this.productMap,
    required this.itemHeightFactor,
    required this.onTap,
    required this.onDoubleTap,
  }) : super(key: key);

  @override
  _AnimatedProductCardState createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<AnimatedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int tapCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      tapCount++;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onTap();
  }

  void _handleDoubleTap() {
    setState(() {
      if (tapCount > 0) {
        tapCount--;
      }
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onDoubleTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onDoubleTap: _handleDoubleTap,
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: Stack(
          children: [
            Card(
              color: Theme.of(context).colorScheme.primary,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height /
                        widget.itemHeightFactor,
                    child: Image.network(
                      widget.product.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.secondary,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes!)
                                  : null,
                            ),
                          );
                        }
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return const Center(child: Icon(Icons.error));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (widget.product.hasDiscount)
                          Row(
                            children: [
                              Text(
                                '${widget.product.price}₽',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              Text(
                                widget.product.oldPrice.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          )
                        else
                          Center(
                            child: Text(
                              '${widget.product.price}₽',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        Center(
                          child: Text(
                            widget.product.storeName,
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (tapCount != 0)
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text(
                    '$tapCount',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
