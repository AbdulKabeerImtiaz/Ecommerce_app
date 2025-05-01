import 'dart:convert';
import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:ecommerce_app_db/constants/error_handling.dart';
import 'package:ecommerce_app_db/constants/global_variables.dart';
import 'package:ecommerce_app_db/constants/utils.dart';
import 'package:ecommerce_app_db/features/admin/models/sales.dart';
import 'package:ecommerce_app_db/models/order.dart';
import 'package:ecommerce_app_db/models/product.dart';
import 'package:ecommerce_app_db/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

class AdminServices {
  Future<Product?> sellProduct({
    required BuildContext context,
    required String name,
    required String description,
    required double price,
    required double quantity,
    required String category,
    required List<File> images,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String token = userProvider.user.token;
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

// Safely cast userId to int
    int? userId = decodedToken['id'] is int
        ? decodedToken['id']
        : int.tryParse(decodedToken['id'].toString());

    //int? userId = userProvider.user.id as int?;

    try {
      final cloudinary = CloudinaryPublic('denfgaxvg', 'uszbstnu');
      List<String> imageUrls = [];

      for (int i = 0; i < images.length; i++) {
        CloudinaryResponse res = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(images[i].path, folder: name),
        );
        imageUrls.add(res.secureUrl);
      }

      Product product = Product(
        name: name,
        description: description,
        quantity: quantity,
        images: imageUrls,
        category: category,
        price: price,
        sellerId: userId,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/products/createProduct'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: product.toJson(),
      );

      Product? createdProduct;

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Product Added Successfully!');
          createdProduct =
              product.copyWith(id: jsonDecode(res.body)['insertId']);
          Navigator.pop(context);
        },
      );
      return createdProduct;
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<List<Product>> fetchAllProducts(
      BuildContext context, int sellerId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];
    try {
      http.Response res = await http.get(
          Uri.parse('$uri/products/getAllProducts?id=$sellerId'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token,
          });

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            productList.add(
              Product.fromJson(
                jsonEncode(
                  jsonDecode(res.body)[i],
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return productList;
  }

  void deleteProduct({
    required BuildContext context,
    required Product product,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // http.Response res = await http.post(
      //   Uri.parse('$uri/admin/delete-product'),
      //   headers: {
      //     'Content-Type': 'application/json; charset=UTF-8',
      //     'x-auth-token': userProvider.user.token,
      //   },
      //   body: jsonEncode({
      //     'id': product.id,
      //   }),
      // );

      http.Response res = await http.delete(
        Uri.parse('$uri/products/deleteProduct?id=${product.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          onSuccess();
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> updateOrderItemStatus({
    required BuildContext context,
    required int orderId,
    required String status,
    required int productId,
    required VoidCallback onSuccess, // Callback after successful update
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final res = await http.post(
        Uri.parse('$uri/sellers/updateStatus'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'orderId': orderId,
          'productId': productId,
          'status': status,
        }),
      );

      if (res.statusCode == 200) {
        // Trigger the success callback
        onSuccess();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order items updated to $status')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update order item status')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating order item status')),
      );
    }
  }

  Future<List<Order>> fetchSellerOrders({
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    int id = userProvider.user.id;
    String role = userProvider.user.role;
    List<Order> orderList = [];
    try {
      http.Response res = await http.get(
          Uri.parse('$uri/order/getAllOrders?id=$id&role=$role'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token,
          });

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          try {
            final List<dynamic> decoded = jsonDecode(res.body);
            for (int i = 0; i < decoded.length; i++) {
              if (decoded[i] != null) {
                orderList.add(Order.fromMap(decoded[i]));
              } else {
                print("Null order at index $i skipped.");
              }
            }
          } catch (e) {
            print("Error inside onSuccess: $e");
            showSnackBar(context, "Failed to load orders: $e");
          }

          // for (int i = 0; i < jsonDecode(res.body).length; i++) {
          //   orderList.add(
          //     Order.fromJson(
          //       jsonEncode(
          //         jsonDecode(res.body)[i],
          //       ),
          //     ),
          //   );
          //   print(res.body);
          // }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    print("-----------------------------");
    print("here");
    print(orderList);
    return orderList;
  }

  Future<Map<String, dynamic>> getEarnings(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Sales> sales = [];
    int totalEarning = 0;
    try {
      http.Response res =
          await http.get(Uri.parse('$uri/sellers/analytics'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      });

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          var response = jsonDecode(res.body);
          totalEarning = response['totalEarnings'];
          sales = [
            Sales('Mobiles', response['mobileEarnings']),
            Sales('Essentials', response['essentialEarnings']),
            Sales('Books', response['booksEarnings']),
            Sales('Appliances', response['applianceEarnings']),
            Sales('Fashion', response['fashionEarnings']),
          ];
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return {
      'sales': sales,
      'totalEarnings': totalEarning,
    };
  }
}
