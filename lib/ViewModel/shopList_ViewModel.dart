import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shopchecker/Model/Product.dart';
// class ShopListNotifier extends StateNotifier<> {
//   ShopListNotifier(): super(null);

// }

class ListViewModel extends StateNotifier<List<Map<String, dynamic>>> {
  final Cart cart;

  ListViewModel(this.cart) : super(cart.cartList);

  List<Map<String, dynamic>> get list => cart.checkCart();

  List write() {
    return list;
  }

  // void addToCart(Map<String, dynamic> item) {
  //   cart.addToCart(item);
  //   state = List.from(cart.cartList); // Обновляем состояние
  // }

  // void removeFromCart(int index) {
  //   cart.removeFromCart(index);
  //   state = List.from(cart.cartList); // Обновляем состояние
  // }
}

final listViewModelProvider =
    StateNotifierProvider<ListViewModel, List<Map<String, dynamic>>>((ref) {
  final cart = ref.watch(cartModelProvider);

  return ListViewModel(cart);
});
