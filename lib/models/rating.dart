import 'dart:convert';

class Rating {
  final int id;
  final int customerId;
  final int productId;
  final double rating;
  final String comment;
  final String createdAt;

  Rating({
    required this.id,
    required this.customerId,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id']?.toInt() ?? 0,
      customerId: map['customer_id']?.toInt() ?? 0,
      productId: map['product_id']?.toInt() ?? 0,
      rating: map['rating']?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      createdAt: map['created_at']?.toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Rating.fromJson(String source) => Rating.fromMap(json.decode(source));
}
