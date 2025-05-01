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

class CartServices {
  void removeFromCart({
    required BuildContext context,
    required Product product,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user.id;

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/cart/delete'),
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
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void updQtyCart({
    required BuildContext context,
    required Product product,
    required int direc,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user.id;

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/cart/update'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'customerId': userId,
          'productId': product.id,
          'direc': direc,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          print('Response body: ${res.body}');

          final updatedUser = User.fromMap(jsonDecode(res.body)['user']);
          userProvider.setUserFromModel(updatedUser);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void deleteAllUsersCart({
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user.id;

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/cart/deleteAll'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'customerId': userId,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // print('Response body: ${res.body}');

          // final updatedUser = User.fromMap(jsonDecode(res.body)['user']);
          // userProvider.setUserFromModel(updatedUser);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
