import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  Map<String, dynamic> recomendCart = {};

  void setRecomendCart(Map<String, dynamic> mapList) {}

  void addToCart(Map<String, dynamic> mapList) {
    bool add = true;
    for (int i = 0; i < cartList.length; i++) {
      if (mapList == cartList[i]) {
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
      cartList.add(mapList);
    }

    totalPrice += mapList['price'];
    if (mapList.containsKey('oldPrice') && mapList['oldPrice'] != null) {
      totalDiscount += mapList['oldPrice'] - mapList['price'];
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

    if (product.containsKey('oldPrice') && product['oldPrice'] != null) {
      totalDiscount -= product['oldPrice'] - product['price'];
    }
    if (totalDiscount < 0) totalDiscount = 0;

    if (!countRemove) {
      cartList.removeAt(index);
    } else {
      if (product.containsKey('count') && product['count'] > 1) {
        cartList[index]['count'] -= 1;
      } else if (!product.containsKey('count')) {
        cartList.removeAt(index);
      } else if (product.containsKey('count') && product['count'] == 1) {
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
