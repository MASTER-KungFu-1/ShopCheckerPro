import 'package:flutter/material.dart';
import 'Model/Model_Services/API_service.dart';
import 'Model/Product.dart';

class ShopViewModel extends ChangeNotifier {
  final ApiService apiService = ApiService();
  List<Product> products = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> loadProducts(String query) async {
    isLoading = true;
    notifyListeners();

    try {
      final perekrestokProducts =
          await apiService.fetchPerekrestokProducts(query);
      final magnitProducts = await apiService.fetchMagnitProducts(query);
      final searchProducts = await apiService.fetchSearchProducts(query);

      products = [...perekrestokProducts, ...magnitProducts, ...searchProducts];
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
