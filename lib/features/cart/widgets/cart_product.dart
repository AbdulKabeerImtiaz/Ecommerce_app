import 'package:ecommerce_app_db/constants/utils.dart';
import 'package:ecommerce_app_db/features/cart/services/cart_services.dart';
import 'package:ecommerce_app_db/features/product_details/services/product_detail_services.dart';
import 'package:ecommerce_app_db/models/product.dart';
import 'package:ecommerce_app_db/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartProduct extends StatefulWidget {
  final int index;
  const CartProduct({super.key, required this.index});

  @override
  State<CartProduct> createState() => _CartProductState();
}

class _CartProductState extends State<CartProduct> {
  final ProductDetailsServices productDetailsServices =
      ProductDetailsServices();
  final CartServices cartServices = CartServices();
  int? qty;

  Product? product;

  @override
  void initState() {
    super.initState();
    fetchMyProduct();
  }

  // void increaseQuantity(Product product) {
  //   productDetailsServices.addToCart(
  //     context: context,
  //     product: product,
  //   );
  // }

  void increaseQuantity(Product product) {
    cartServices.updQtyCart(
      context: context,
      product: product,
      direc: 1,
    );
    qty = qty! + 1;
    //quantity = qty!;
    setState(() {});
  }

  void decreaseQuantity(Product product) {
    cartServices.updQtyCart(
      context: context,
      product: product,
      direc: 2,
    );
    qty = qty! - 1;
    //quantity = qty!;
    setState(() {});
  }

  // void fetchMyProduct() async {
  //   final productCart = context.watch<UserProvider>().user.cart![widget.index];
  //   product = await productDetailsServices.getProductByID(
  //       context: context, id: productCart.productId);
  //   if (product == null) {
  //     showSnackBar(context, "Product not found or deleted from store.");
  //   }
  //   setState(() {});
  // }

  void fetchMyProduct() async {
    final productCart = context.read<UserProvider>().user.cart![widget.index];
    product = await productDetailsServices.getProductByID(
      context: context,
      id: productCart.productId,
    );

    if (product == null) {
      showSnackBar(context, "Product not found or deleted from store.");
    } else {
      qty = productCart.quantity;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //final productCart = context.watch<UserProvider>().user.cart![widget.index];
    if (product == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // final quantity = productCart.quantity;
    // qty = quantity;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Row(
            children: [
              Image.network(
                product!.images[0],
                fit: BoxFit.contain,
                height: 135,
                width: 135,
              ),
              Column(
                children: [
                  Container(
                    width: 235,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      product!.name,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  Container(
                    width: 235,
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Text(
                      '\$${product!.price}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  Container(
                    width: 235,
                    padding: const EdgeInsets.only(left: 10),
                    child: const Text('Eligible for FREE Shipping'),
                  ),
                  Container(
                    width: 235,
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: const Text(
                      'In Stock',
                      style: TextStyle(
                        color: Colors.teal,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.black12,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => decreaseQuantity(product!),
                      child: Container(
                        width: 35,
                        height: 32,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.remove,
                          size: 18,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12, width: 1.5),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Container(
                        width: 35,
                        height: 32,
                        alignment: Alignment.center,
                        child: Text(
                          qty.toString(),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => increaseQuantity(product!),
                      child: Container(
                        width: 35,
                        height: 32,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.add,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
