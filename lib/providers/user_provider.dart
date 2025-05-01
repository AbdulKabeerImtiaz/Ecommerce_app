import 'package:ecommerce_app_db/models/cart_item.dart';
import 'package:ecommerce_app_db/models/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: 0,
    name: '',
    email: '',
    password: '',
    role: '',
    createdAt: '',
    address: '',
    type: '',
    token: '',
    cart: [],
  );
  User get user => _user;
  // void setuser(String user) {
  //   _user = User.fromJson(user);
  //   notifyListeners();
  // }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  // NEW: Function to update the entire cart
  void setCart(List<CartItem> cart) {
    _user = User(
      id: _user.id,
      name: _user.name,
      email: _user.email,
      password: _user.password,
      role: _user.role,
      createdAt: _user.createdAt,
      address: _user.address,
      type: _user.type,
      token: _user.token,
      cart: cart,
    );
    notifyListeners();
  }

  // NEW: Function to update quantity of a specific cart item
  void updateCartItemQuantity(int productId, int newQuantity) {
    final updatedCart = _user.cart!.map((item) {
      if (item.productId == productId) {
        return CartItem(
          id: item.id,
          customerId: item.customerId,
          productId: item.productId,
          quantity: newQuantity,
        );
      }
      return item;
    }).toList();

    setCart(updatedCart);
  }

  // NEW: Function to remove an item from cart
  void removeCartItem(int productId) {
    final updatedCart =
        _user.cart!.where((item) => item.productId != productId).toList();
    setCart(updatedCart);
  }
}
