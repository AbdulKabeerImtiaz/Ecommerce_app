import 'dart:convert';

import 'package:ecommerce_app_db/models/cart_item.dart';
import 'package:ecommerce_app_db/models/order.dart';

class User {
  //final String id;
  final int id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? createdAt;
  final String? address;
  final String? type;
  final String token;
  final List<CartItem>? cart;
  final List<Order>? orders;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.createdAt,
    required this.address,
    required this.type,
    required this.token,
    this.cart,
    this.orders,
    //required String type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'created_at': createdAt,
      'address': address,
      'type': type,
      'token': token,
      'cart': cart,
      'orders': orders
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'customer',
      //createdAt: map['created_at'] ?? '',
      createdAt: map['created_at']?.toString() ?? '',
      address: map['address'] ?? '',
      type: map['type'] ?? '',
      token: map['token'] ?? '',
      // cart: map['cart'] != null
      //     ? List<CartItem>.from(
      //         map['cart']?.map(
      //           (x) => CartItem.fromMap(x),
      //         ),
      //       )
      //     : null,
      cart: map['cart'] != null
          ? List<CartItem>.from(map['cart'].map((x) => CartItem.fromMap(x)))
          : [],
      orders: map['orders'] != null
          ? List<Order>.from(map['orders'].map((x) => Order.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  //factory User.fromJson(String source) => User.fromMap(json.decode(source));
  factory User.fromJson(String source) {
    final decoded = json.decode(source);
    if (decoded is Map<String, dynamic>) {
      return User.fromMap(decoded);
    } else {
      throw FormatException('Invalid JSON format for User: $decoded');
    }
  }

  User copyWith({
    //String? id,
    int? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? address,
    String? createdAt,
    String? type,
    String? token,
    List<CartItem>? cart,
    List<Order>? orders,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      token: token ?? this.token,
      cart: cart ?? this.cart,
      orders: orders ?? this.orders,
    );
  }
}
