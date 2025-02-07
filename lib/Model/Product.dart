import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import "Model_Services/API_service.dart";

class Product {
  final String name;
  final String storeName;
  final String imageUrl;
  final double price;
  final double? oldPrice;
  final bool hasDiscount;
  final String? discountPercent;

  Product({
    required this.name,
    this.storeName = "поиск",
    required this.imageUrl,
    required this.price,
    this.oldPrice,
    required this.hasDiscount,
    this.discountPercent,
  });

  factory Product.fromPerekrestokJson(Map<String, dynamic> json) {
    if (json['image_url'].runtimeType != String) {
      json['image_url'] = json["image_url"].toString();
    }
    if (json['price'].runtimeType != double) {
      json['price'] = double.parse(json["price"].replaceFirst(',', '.'));
    }
    if (json['oldprice'].runtimeType != double && json['oldprice'] != null) {
      json['oldprice'] = double.parse(json["oldprice"].replaceFirst(',', '.'));
    }
    if (json['discountPercent'].runtimeType != String &&
        json['discountPercent'] != null) {
      json['discountPercent'] = json["discountPercent"].toString();
    }
    return Product(
      name: json['name'],
      storeName: json['store_name'],
      imageUrl: json['image_url'],
      price: json['price'] ?? 0.0,
      oldPrice: json['oldprice'],
      hasDiscount: json['discount'] ?? false,
      discountPercent: json['discountPercent'],
    );
  }

  factory Product.fromMagnitJson(Map<String, dynamic> json) {
    if (json['image_url'].runtimeType != String) {
      json['image_url'] = json["image_url"].toString();
    }
    if (json['price'].runtimeType != double) {
      json['price'] = double.parse(json["price"].replaceFirst(',', '.'));
    }
    if (json['oldprice'].runtimeType != double && json['oldprice'] != null) {
      json['oldprice'] = double.parse(json["oldprice"].replaceFirst(',', '.'));
    }
    if (json['discountPercent'].runtimeType != String &&
        json['discountPercent'] != null) {
      json['discountPercent'] = json["discountPercent"].toString();
    }
    return Product(
      name: json['name'],
      storeName: 'magnit',
      imageUrl: json['imageUrl'],
      price: json['price'] ?? 0.0,
      oldPrice: json['oldPrice'],
      hasDiscount: json['discount'] ?? false,
      discountPercent: json['discountPercent'],
    );
  }

  factory Product.fromSearchJson(Map<String, dynamic> json) {
    if (json['image_url'].runtimeType != String) {
      json['image_url'] = json["image_url"].toString();
    }
    if (json['price'].runtimeType != double) {
      json['price'] = double.parse(json["price"].replaceFirst(',', '.'));
    }
    if (json['oldprice'].runtimeType != double && json['oldprice'] != null) {
      json['oldprice'] = double.parse(json["oldprice"].replaceFirst(',', '.'));
    }
    if (json['discountPercent'].runtimeType != String &&
        json['discountPercent'] != null) {
      json['discountPercent'] = json["discountPercent"].toString();
    }

    return Product(
      name: json['name'],
      storeName: json['store_name'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      price: json['price'],
      oldPrice: json['oldprice'],
      hasDiscount: json['discount'] ?? false,
      discountPercent: json['discountPercent'],
    );
  }
}

class CacheSystem {
  static final CacheSystem _instance = CacheSystem._internal();

  factory CacheSystem() {
    return _instance;
  }

  CacheSystem._internal();

  Map<String, dynamic> cacheList = {};

  int cacheListLength() {
    return cacheList.length;
  }

  Map<String, dynamic> getCache() {
    return cacheList;
  }

  void addToCache(String name, dynamic elementCache) {
    cacheList.putIfAbsent(name, () => elementCache);
  }

  void addToCacheList(List<Map<String, dynamic>> elements) {
    for (var element in elements) {
      addToCache(element['name'], element['element']);
    }
  }

  void clearCache() {
    cacheList.clear();
  }

  void removeFromCache(String name) {
    cacheList.remove(name);
  }

  void updateCache(String name, dynamic elementCache) {
    cacheList[name] = elementCache;
  }

  void updateCacheList(List<Map<String, dynamic>> elements) {
    for (var element in elements) {
      updateCache(element['name'], element['element']);
    }
  }

  bool isCached(String name) {
    return cacheList.containsKey(name);
  }

  dynamic findElement(String key) {
    return cacheList[key];
  }

  Map<String, dynamic> findElementList(List<String> keys) {
    Map<String, dynamic> result = {};
    for (String key in keys) {
      if (cacheList.containsKey(key)) {
        result[key] = cacheList[key];
      }
    }
    return result;
  }
}

class Cart extends ChangeNotifier {
  List<Map<String, dynamic>> cartList = [];
  double totalPrice = 0.0;
  double totalDiscount = 0.0;
  List recomendCart = [];
  Map<String, dynamic> recCart = {};
  ApiService api = ApiService();

  // Future<List> addIntoRecomendCart(index) async {
  //   if (recomendCart.isEmpty) {
  //     return [];
  //   } else {
  //     List listRec = recomendCart;
  //     Map<String, dynamic> recCart = cartList[index];
  //     try {
  //       listRec.add(await api.postRecomendedCart(recCart));
  //       recomendCart = listRec;
  //     } catch (e) {
  //       print(e.toString());
  //       listRec.add([]);
  //     }

  //     return listRec;
  //   }
  // }

  Future<List> setRecomendCart() async {
    // Всегда передаём данные в формате: {'products': cartList}
    recCart = {'products': cartList};
    if (cartList.isEmpty) {
      return [];
    }
    final listRec = await api.postRecomendedCart(recCart);
    if (listRec.isEmpty) {
      print('Ошибка кластеризации');
      return [];
    }

    recomendCart = listRec;
    notifyListeners();
    return recomendCart;
  }

  void addToCart(Map<String, dynamic> mapList, [bool inActiveCart = false]) {
    bool add = true;

    for (int i = 0; i < cartList.length; i++) {
      if (mapList['name'] == cartList[i]['name']) {
        if (cartList[i].containsKey('count')) {
          cartList[i]['count'] = cartList[i]['count'] + 1;
        } else {
          cartList[i]['count'] = 2;
        }
        add = false;
        break;
      }
    }

    if (add) {
      if (mapList.containsKey('image_url')) {
        mapList['imageUrl'] = mapList['image_url'];
      }

      cartList.add(mapList);
    }
    String info1 = '';
    if (mapList['price'].runtimeType == String) {
      mapList['price'] = double.parse(mapList['price'].replaceFirst(',', '.'));
    }
    totalPrice += mapList['price'];
    if (mapList.containsKey('oldPrice') && mapList['oldPrice'] != null) {
      if (mapList['oldPrice'].runtimeType == String) {
        mapList['oldPrice'] =
            double.parse(mapList['oldPrice'].replaceFirst(',', '.'));
      }
      info1 = (mapList['oldPrice'] - mapList['price']).toStringAsFixed(2);
      totalDiscount += double.parse(info1);
    }
    notifyListeners();
  }

  void clearCart() {
    cartList.clear();
    totalPrice = 0.0;
    totalDiscount = 0.0;
    notifyListeners();
  }

  void removeFromCart(int index, [bool countRemove = false]) {
    final product = cartList[index];

    totalPrice -= product['price'];

    if (totalPrice < 0) totalPrice = 0;
    String info1 = '';
    if (product.containsKey('oldPrice') && product['oldPrice'] != null) {
      info1 = (product['oldPrice'] - product['price']).toStringAsFixed(2);

      totalDiscount -= double.parse(info1);
    }
    if (totalDiscount < 0) totalDiscount = 0;

    if (!countRemove) {
      try {
        if (product.containsKey('count') && product['count'] > 1) {
          totalPrice -= product['price'] * (product['count'] - 1);
          if (product.containsKey('oldPrice') && product['oldPrice'] != null) {
            info1 = (product['oldPrice'] - product['price']).toStringAsFixed(2);

            totalDiscount -= double.parse(info1) * product['count'] - 1;
          }
          if (totalPrice < 0) totalPrice = 0;
          if (totalDiscount < 0) totalDiscount = 0;
        }
        recomendCart.removeAt(index);
      } catch (e) {}

      cartList.removeAt(index);
    } else {
      if (product.containsKey('count') && product['count'] > 1) {
        cartList[index]['count'] -= 1;
      } else if (!product.containsKey('count')) {
        recomendCart.removeAt(index);
        cartList.removeAt(index);
      } else if (product.containsKey('count') && product['count'] == 1) {
        recomendCart.removeAt(index);
        cartList.removeAt(index);
      }
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> checkCart() {
    return cartList;
  }
}

final cartModelProvider = ChangeNotifierProvider((ref) => Cart());
