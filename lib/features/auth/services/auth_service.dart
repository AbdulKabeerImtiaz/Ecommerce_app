import 'dart:convert';

import 'package:ecommerce_app_db/common/widgets/bottom_bar.dart';
import 'package:ecommerce_app_db/constants/error_handling.dart';
import 'package:ecommerce_app_db/constants/global_variables.dart';
import 'package:ecommerce_app_db/constants/utils.dart';
import 'package:ecommerce_app_db/features/admin/screens/admin_screen.dart';
import 'package:ecommerce_app_db/features/home/screens/home_screen.dart';
import 'package:ecommerce_app_db/models/user.dart';
import 'package:ecommerce_app_db/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:ecommerce_app_db/backend/routes/userRoutes.js';

class AuthService {
  // checkOnSuccess(BuildContext context, http.Response res) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final data = jsonDecode(res.body);

  //   Map<String, dynamic> userData = data['user'];
  //   userData['token'] = data['token'];
  //   print('Token from response: ${data['token']}');
  //   await prefs.setString('x-auth-token', data['token']);

  //   Provider.of<UserProvider>(context, listen: false)
  //       .setuser(jsonEncode(userData));

  //   Navigator.pushNamedAndRemoveUntil(
  //     context,
  //     BottomBar.routeName,
  //     (route) => false,
  //   );
  // }

  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      User user = User(
        id: 0,
        name: name,
        email: email,
        password: password,
        role: '',
        createdAt: '',
        address: '',
        type: '',
        token: '',
        cart: [],
      );

      http.Response res = await http.post(
        Uri.parse('$uri/users/register'),
        body: jsonEncode({
          'name': user.name,
          'email': user.email,
          'password': user.password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
              context, "Account created! Login with the same credentials");
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      //print('$uri');
      http.Response res = await http.post(
        Uri.parse('$uri/users/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );
      print(res.body);
      // final data = jsonDecode(res.body);
      // Map<String, dynamic> userData = data['user'];
      // userData['token'] = data['token'];
      // print('Token from response: ${data['token']}');
      // Future<void> httpErrorHandle({
      //   required http.Response response,
      //   required BuildContext context,
      //   required VoidCallback onSuccess,
      // }) async {
      //   switch (response.statusCode) {
      //     case 200:
      //       await checkOnSuccess(
      //           context, response); // only enters here if success code
      //       break;
      //     default:
      //       showSnackBar(context, response.body);
      //   }
      // }

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          // final data = jsonDecode(res.body);

          // Map<String, dynamic> userData = data['user'];
          // userData['token'] = data['token'];
          // print('Token from response: ${data['token']}');

          final data = jsonDecode(res.body) as Map<String, dynamic>;
          print('raw user map: ${data['user']} (${data['user'].runtimeType})');

          final token = data['token'] as String;
          final userMap = data['user'] as Map<String, dynamic>;

          // inject token into the user map
          userMap['token'] = token;

          // parse into our Dart model
          final user = User.fromMap(userMap);
          print('parsed User: $user');

          await prefs.setString('x-auth-token', data['token']);

          // Provider.of<UserProvider>(context, listen: false)
          //     .setuser(jsonEncode(userData));
          Provider.of<UserProvider>(context, listen: false).setUser(user);
          print(res.body);
          // Navigator.pushNamedAndRemoveUntil(
          //   context,
          //   BottomBar.routeName,
          //   (route) => false,
          // );
          if (user.role == 'seller') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AdminScreen
                  .routeName, // Replace with your actual seller screen route
              (route) => false,
            );
          } else if (user.role == 'customer') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              BottomBar.routeName,
              (route) => false,
            );
          } else {
            // Optional: handle unknown role
            //print('Unknown role: ${userData['role']}');
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
      //print(e.toString());
    }
  }

  void getUserData(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null) {
        prefs.setString('x-auth-token', '');
      }

      var tokenRes = await http.post(
        Uri.parse('$uri/users/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!
        },
      );

      var response = jsonDecode(tokenRes.body);
      if (response == true) {
        http.Response userRes = await http.get(
          Uri.parse('$uri/users/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token
          },
        );
        final data = jsonDecode(userRes.body) as Map<String, dynamic>;
        data['token'] = token;
        final user = User.fromMap(data);
        var userProvider = Provider.of<UserProvider>(context, listen: false);
        //userProvider.setUser(userRes.body);
        userProvider.setUser(user);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void signUpSeller({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required String storeName,
  }) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      print("Something is empty here!!");
      return;
    }
    try {
      // Set role and createdAt dynamically
      final String role = 'seller';
      //final String createdAt = DateTime.now().toIso8601String();

      User user = User(
        id: 0,
        name: name,
        email: email,
        password: password,
        role: role,
        createdAt: '',
        address: '',
        type: '',
        token: '',
      );

      // print('Store Name: $storeName');
      // if (email.isEmpty || password.isEmpty || name.isEmpty) {
      //   print("Something is empty here!!");
      //   return;
      // }

      // final body = {
      //   'name': user.name,
      //   'email': user.email,
      //   'password': user.password,
      //   'role': user.role,
      //   'createdAt': user.createdAt,
      //   'storeName': storeName,
      // };
      // print("Request Body: $body");

      http.Response res = await http.post(
        Uri.parse('$uri/sellers/register'),
        body: jsonEncode({
          'name': user.name,
          'email': user.email,
          'password': user.password,
          'role': user.role,
          'storeName': storeName,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            "Account created! Login with the same credentials",
          );
        },
      );
    } catch (e) {
      showSnackBar(context, "Error!!!!!!!!!!!!!!!!!!!!!!!");
    }
  }
}
