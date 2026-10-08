import 'package:flutter/foundation.dart';

class CartData {
  static final ValueNotifier<List<Map<String, dynamic>>> items =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  static int toInt(dynamic value, [int defaultValue = 0]) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }

    return defaultValue;
  }

  static void addToCart(Map<String, dynamic> product) {
    List<Map<String, dynamic>> cart =
        List<Map<String, dynamic>>.from(items.value);

    int index = cart.indexWhere(
      (item) => item['name'] == product['name'],
    );

    if (index != -1) {
      Map<String, dynamic> item =
          Map<String, dynamic>.from(cart[index]);

      int quantity = toInt(item['quantity'], 1);

      item['quantity'] = quantity + 1;

      cart[index] = item;
    } else {
      Map<String, dynamic> newProduct =
          Map<String, dynamic>.from(product);

      newProduct['quantity'] = 1;

      cart.add(newProduct);
    }

    items.value = cart;
  }

  static void increase(int index) {
    if (index < 0 || index >= items.value.length) {
      return;
    }

    List<Map<String, dynamic>> cart =
        List<Map<String, dynamic>>.from(items.value);

    Map<String, dynamic> item =
        Map<String, dynamic>.from(cart[index]);

    int quantity = toInt(item['quantity'], 1);

    item['quantity'] = quantity + 1;

    cart[index] = item;

    items.value = cart;
  }

  static void decrease(int index) {
    if (index < 0 || index >= items.value.length) {
      return;
    }

    List<Map<String, dynamic>> cart =
        List<Map<String, dynamic>>.from(items.value);

    Map<String, dynamic> item =
        Map<String, dynamic>.from(cart[index]);

    int quantity = toInt(item['quantity'], 1);

    if (quantity > 1) {
      item['quantity'] = quantity - 1;
      cart[index] = item;
    } else {
      cart.removeAt(index);
    }

    items.value = cart;
  }

  static void removeFromCart(int index) {
    if (index < 0 || index >= items.value.length) {
      return;
    }

    List<Map<String, dynamic>> cart =
        List<Map<String, dynamic>>.from(items.value);

    cart.removeAt(index);

    items.value = cart;
  }

  static void clearCart() {
    items.value = [];
  }

  static int get itemCount {
    int count = 0;

    for (Map<String, dynamic> item in items.value) {
      int quantity = toInt(item['quantity'], 1);
      count += quantity;
    }

    return count;
  }

  static int get subtotal {
    int total = 0;

    for (Map<String, dynamic> item in items.value) {
      int price = toInt(item['price']);
      int quantity = toInt(item['quantity'], 1);

      total += price * quantity;
    }

    return total;
  }

  static int get discount {
    if (subtotal >= 5000) {
      return 1000;
    }

    return 0;
  }

  static int get deliveryCharges {
    if (items.value.isEmpty) {
      return 0;
    }

    return 0;
  }

  static int get total {
    return subtotal - discount + deliveryCharges;
  }
}