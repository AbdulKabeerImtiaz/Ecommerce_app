import 'dart:convert';

import 'package:ecommerce_app_db/models/rating.dart';

class Product {
  final String name;
  final String description;
  final double quantity;
  final List<String> images;
  final String category;
  final double price;
  final int? id;
  final int? sellerId;
  final List<Rating>? rating;
  Product({
    required this.name,
    required this.description,
    required this.quantity,
    required this.images,
    required this.category,
    required this.price,
    this.id,
    this.sellerId,
    this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'images': images,
      'category': category,
      'price': price,
      'id': id,
      'sellerId': sellerId,
      'rating': rating,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      quantity: map['quantity']?.toDouble() ?? 0.0,
      images: List<String>.from(map['images']),
      category: map['category'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id']?.toString() ?? ''),
      sellerId: map['sellerId'] is int
          ? map['sellerId']
          : int.tryParse(map['sellerId']?.toString() ?? ''),
      // id: map['id'],
      // userId: map['userId'],
      rating: map['rating'] != null
          ? List<Rating>.from(
              map['rating']?.map(
                (x) => Rating.fromMap(x),
              ),
            )
          : null,
    );
  }

  Product copyWith({
    // int? id,
    // String? name,
    // String? description,
    // double? price,
    // double? quantity,
    // List<String>? images,
    // String? category,
    // int? sellerId,
    // final List<Rating>? rating
    final String? name,
    final String? description,
    final double? quantity,
    final List<String>? images,
    final String? category,
    final double? price,
    final int? id,
    final int? sellerId,
    final List<Rating>? rating,
  }) {
    return Product(
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      images: images ?? this.images,
      category: category ?? this.category,
      price: price ?? this.price,
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      rating: rating ?? this.rating,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));
}
