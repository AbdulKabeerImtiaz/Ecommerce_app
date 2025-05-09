import 'dart:convert';

import 'package:ecommerce_app_db/models/product.dart';

class Order {
  final int id;
  final List<Product> products;
  final List<int> quantity;
  final String address;
  final int userId;
  final int orderedAt;
  final String status;
  final double totalPrice;
  Order({
    required this.id,
    required this.products,
    required this.quantity,
    required this.address,
    required this.userId,
    required this.orderedAt,
    required this.status,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'products': products.map((x) => x.toMap()).toList(),
      'quantity': quantity,
      'address': address,
      'userId': userId,
      'orderedAt': orderedAt,
      'status': status,
      'totalPrice': totalPrice,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      // id: map['id']?.toInt() ?? 0,
      // products: List<Product>.from(
      //     map['products']?.map((x) => Product.fromMap(x['product']))),
      // quantity: List<int>.from(
      //   map['products']?.map(
      //     (x) => x['quantity'],
      //   ),
      // ),
      // address: map['address'] ?? '',
      // userId: map['userId']?.toInt() ?? 0,
      // orderedAt: map['orderedAt']?.toInt() ?? 0,
      // status: map['status'] ?? '',
      // totalPrice: map['totalPrice']?.toDouble() ?? 0.0,

      id: map['id']?.toInt() ?? 0,
      products: List<Product>.from(
        (map['products'] ?? []).map((x) => Product.fromMap(x)),
      ),
      quantity: List<int>.from(map['quantity'] ?? []),
      address: map['address'] ?? '',
      userId: map['userId']?.toInt() ?? 0,
      orderedAt: map['orderedAt']?.toInt() ?? 0,
      status: map['status'] ?? '',
      totalPrice: double.tryParse(map['totalPrice'].toString()) ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));
}
