import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopcheckerpro/ViewModel/Products_ViewModel.dart';
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
    if (value.length <= 3) {
    } else {
      int debounceDuration = value.length <= 3 ? 1000 : 500;

      _debounce = Timer(Duration(milliseconds: debounceDuration), () {
        ref.read(shopViewModelProvider).loadProducts(value, context);
      });
    }
  }

  Widget buildGrid(int crossAxisCount, double itemHeightFactor) {
    final viewModel = ref.watch(shopViewModelProvider);
    return MasonryGridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      itemCount: viewModel.products.length,
      itemBuilder: (BuildContext context, int index) {
        final product = viewModel.products[index];

        return GestureDetector(
          onTap: () => viewModel.handleTapOutside(
            context,
          ),
          child: Card(
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / itemHeightFactor,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
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
                        product.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (product.hasDiscount)
                        Text(
                          'Старая цена: ${product.oldPrice}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.error,
                            decoration: TextDecoration.lineThrough,
                            decorationColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      Text(
                        'Цена: ${product.price} руб.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        'Магазин: ${product.storeName}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                  width: MediaQuery.of(context).size.width,
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
                // SizedBox(
                //     height: 55,
                //     width: 50,
                //     child: IconButton(
                //       icon: const Icon(Icons.filter_list_outlined),
                //       onPressed: () {},
                //     )),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            onTap: (int index) {
              if (index == 1) {
                Navigator.pushNamed(context, '/cart');
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
                icon: Icon(Icons.person_outlined),
                label: "Профиль",
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
