import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopcheckerpro/Model/Model_Services/API_service.dart';
import 'package:shopcheckerpro/Model/Product.dart';

class ShopViewModel extends ChangeNotifier {
  final ApiService apiService = ApiService();
  final FocusNode searchFocusNode = FocusNode();
  final List<FocusNode> buttonFocusNodes = [];
  List<Product> products = [];
  bool isLoading = false;
  String errorMessage = '';

  ShopViewModel() {
    initializeFocusNodes(200);
  }

  void initializeFocusNodes(int count) {
    for (int i = 0; i < count; i++) {
      buttonFocusNodes.add(FocusNode());
    }
    notifyListeners();
  }

  Future<void> loadProducts(
    String query,
    BuildContext context, [
    bool search = true,
    bool? magnit,
    bool? perekrestok,
    bool? lenta,
    bool? ashan,
  ]) async {
    isLoading = true;
    notifyListeners();

    products = [];
    try {
      if (!CacheSystem().isCached(query)) {
        if (!search) {
          if (magnit == true) {
            products += [...await apiService.fetchMagnitProducts(query)];
          }
          if (perekrestok == true) {
            products += [...await apiService.fetchPerekrestokProducts(query)];
          }
          // if (lenta == true) {
          //   products += [...await apiService.fetchLentaProducts(query)];
          // }
          // if (ashan == true) {
          //   products += [...await apiService.fetchAshanProducts(query)];
          // }
        } else {
          final searchProducts = await apiService.fetchSearchProducts(query);
          products += [...searchProducts];
          CacheSystem().addToCache(query, searchProducts);
        }
      } else {
        print('используем кэш');
        products = CacheSystem().findElement(query);
      }
    } catch (e) {
      print(e);
      errorMessage = e.toString();
      if (errorMessage.contains(
          "ClientException with SocketException: Connection failed")) {
        errorMessage = "Нет соединения с сервером, попробуйте снова.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: "Перезагрузка",
            onPressed: () async {
              await Future.delayed(const Duration(seconds: 1));
              loadProducts(
                  query, context, search, magnit, perekrestok, lenta, ashan);
            },
          ),
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addFocusNode() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      buttonFocusNodes.add(FocusNode());
      notifyListeners();
    });
  }

  void removeFocusNode(int index) {
    if (index >= 0 && index < buttonFocusNodes.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        buttonFocusNodes.removeAt(index).dispose();
        notifyListeners();
      });
    }
  }

  void handleTapOutside(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  void handleFocusChange(BuildContext context, int index) {
    if (index >= 0 && index < buttonFocusNodes.length) {
      FocusScope.of(context).requestFocus(buttonFocusNodes[index]);
    }
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    for (var node in buttonFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}

final shopViewModelProvider = ChangeNotifierProvider((ref) => ShopViewModel());
