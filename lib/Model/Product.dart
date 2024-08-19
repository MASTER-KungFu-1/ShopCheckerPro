import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class Product {
  final String name;
  final String storeName;
  final String imageUrl;
  final String price;
  final String? oldPrice;
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
    if (json['price'].runtimeType != String) {
      json['price'] = json["price"].toString();
    }
    if (json['oldprice'].runtimeType != String && json['oldprice'] != null) {
      json['price'] = json["price"].toString();
    }
    if (json['discountPercent'].runtimeType != String &&
        json['discountPercent'] != null) {
      json['discountPercent'] = json["discountPercent"].toString();
    }
    return Product(
      name: json['name'],
      storeName: json['store_name'],
      imageUrl: json['image_url'],
      price: json['price'] ?? "Акция",
      oldPrice: json['oldprice'],
      hasDiscount: json['discount'] ?? false,
      discountPercent: json['discountPercent'],
    );
  }

  factory Product.fromMagnitJson(Map<String, dynamic> json) {
    if (json['image_url'].runtimeType != String) {
      json['image_url'] = json["image_url"].toString();
    }
    if (json['price'].runtimeType != String) {
      json['price'] = json["price"].toString();
    }
    if (json['oldprice'].runtimeType != String && json['oldprice'] != null) {
      json['price'] = json["price"].toString();
    }
    if (json['discountPercent'].runtimeType != String &&
        json['discountPercent'] != null) {
      json['discountPercent'] = json["discountPercent"].toString();
    }
    return Product(
      name: json['name'],
      storeName: 'magnit',
      imageUrl: json['imageUrl'],
      price: json['price'].toString(),
      oldPrice: json['oldPrice'],
      hasDiscount: json['discount'] ?? false,
      discountPercent: json['discountPercent'],
    );
  }

  factory Product.fromSearchJson(Map<String, dynamic> json) {
    if (json['image_url'].runtimeType != String) {
      json['image_url'] = json["image_url"].toString();
    }
    if (json['price'].runtimeType != String) {
      json['price'] = json["price"].toString();
    }
    if (json['oldprice'].runtimeType != String && json['oldprice'] != null) {
      json['oldprice'] = json["oldprice"].toString();
    }
    if (json['discountPercent'].runtimeType != String &&
        json['discountPercent'] != null) {
      json['discountPercent'] = json["discountPercent"].toString();
    }

    return Product(
      name: json['name'],
      storeName: json['store_name'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      price: json['price'].toString(),
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

  void addToCart(Map<String, dynamic> mapList) {
    cartList.add(mapList);
    totalPrice += double.parse(mapList['price']);
    if (mapList.containsKey('oldPrice') && mapList['oldPrice'] != null) {
      totalDiscount +=
          double.parse(mapList['oldPrice']) - double.parse(mapList['price']);
    }
    notifyListeners();
  }

  void clearCart() {
    cartList.clear();
    totalPrice = 0.0;
    totalDiscount = 0.0;
    notifyListeners();
  }

  void removeFromCart(int index) {
    final product = cartList[index];

    totalPrice -= double.parse(product['price']);
    if (totalPrice < 0) totalPrice = 0;

    if (product.containsKey('oldPrice') && product['oldPrice'] != null) {
      totalDiscount -=
          double.parse(product['oldPrice']) - double.parse(product['price']);
    }
    if (totalDiscount < 0) totalDiscount = 0;
    cartList.removeAt(index);
    notifyListeners();
  }

  List<Map<String, dynamic>> checkCart() {
    return cartList;
  }
}

final cartModelProvider = ChangeNotifierProvider((ref) => Cart());
