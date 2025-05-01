import 'dart:convert';

import 'package:ecommerce_app_db/constants/error_handling.dart';
import 'package:ecommerce_app_db/constants/global_variables.dart';
import 'package:ecommerce_app_db/constants/utils.dart';
import 'package:ecommerce_app_db/models/product.dart';
import 'package:ecommerce_app_db/models/user.dart';
import 'package:ecommerce_app_db/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

class ProductDetailsServices {
  void addToCart({
    required BuildContext context,
    required Product product,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    //final userId = Provider.of<UserProvider>(context, listen: false).user.id;
    final userId = userProvider.user.id;
    // print('user token: ${userProvider.user.token}');

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/cart/add'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'customerId': userId,
          'productId': product.id,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          print('Response body: ${res.body}');

          final updatedUser = User.fromMap(jsonDecode(res.body)['user']);
          userProvider.setUserFromModel(updatedUser);
          // User user =
          //     userProvider.user.copyWith(cart: jsonDecode(res.body)['cart']);
          // userProvider.setUserFromModel(user);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void rateProduct({
    required BuildContext context,
    required Product product,
    required String comment,
    required double rating,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String token = userProvider.user.token;
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

// Safely cast userId to int
    int? customer_id = decodedToken['id'] is int
        ? decodedToken['id']
        : int.tryParse(decodedToken['id'].toString());

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/reviews/rateProduct'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'customer_id': customer_id,
          'product_id': product.id!,
          'comment': comment,
          'rating': rating,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {},
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<String?> fetchStoreName({
    required BuildContext context,
    required Product product,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String? storeName;
    print(product.id);
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/products/getProductStoreName/?id=${product.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );
      if (res.statusCode == 200) {
        storeName = jsonDecode(res.body)['storeName'];
      } else {
        showSnackBar(context, res.body); // or handle error properly
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }

    return storeName;
  }

  Future<Product?> getProductByID({
    required BuildContext context,
    required int id,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Product? product;
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/products/getProductById?id=$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return Product.fromJson(json);
      } else {
        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {},
        );
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return null;
  }
}
