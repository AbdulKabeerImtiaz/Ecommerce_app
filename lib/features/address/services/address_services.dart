import 'dart:convert';

import 'package:ecommerce_app_db/constants/error_handling.dart';
import 'package:ecommerce_app_db/constants/global_variables.dart';
import 'package:ecommerce_app_db/constants/utils.dart';
import 'package:ecommerce_app_db/models/product.dart';
import 'package:ecommerce_app_db/models/user.dart';
import 'package:ecommerce_app_db/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddressServices {
  void saveUserAddress({
    required BuildContext context,
    required String address,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    int id = userProvider.user.id;

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/users/addAddress'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': id,
          'address': address,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // User user = userProvider.user.copyWith(
          //   address: jsonDecode(res.body)['address'],
          // );
          final updatedUser = User.fromMap(jsonDecode(res.body)['user']);
          userProvider.setUserFromModel(updatedUser);
          //userProvider.setUserFromModel(user);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get all the products
  void placeOrder({
    required BuildContext context,
    required String address,
    required double totalSum,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await http.post(Uri.parse('$uri/order/placeOrder'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token,
          },
          body: jsonEncode({
            'userId': userProvider.user.id,
            'cart': userProvider.user.cart,
            'totalPrice': totalSum,
            'address': address,
          }));

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Your order has been placed!');
          User user = userProvider.user.copyWith(
            cart: [],
          );
          userProvider.setUserFromModel(user);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void deleteProduct({
    required BuildContext context,
    required Product product,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/delete-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': product.id,
        }),
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
}
