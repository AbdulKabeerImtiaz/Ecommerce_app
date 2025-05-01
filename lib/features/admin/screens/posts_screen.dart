import 'package:ecommerce_app_db/constants/loader.dart';
import 'package:ecommerce_app_db/features/account/widgets/single_product.dart';
import 'package:ecommerce_app_db/features/admin/screens/add_product_screen.dart';
import 'package:ecommerce_app_db/features/admin/services/admin_services.dart';
import 'package:ecommerce_app_db/models/product.dart';
import 'package:ecommerce_app_db/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<Product>? products = [];
  final AdminServices adminServices = AdminServices();
  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  fetchAllProducts() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String token = userProvider.user.token;
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int? sellerId = decodedToken['id'] is int
        ? decodedToken['id']
        : int.tryParse(decodedToken['id'].toString());
    products = await adminServices.fetchAllProducts(context, sellerId!);
    setState(() {});
  }

  void deleteProduct(Product product, int index) {
    adminServices.deleteProduct(
      context: context,
      product: product,
      onSuccess: () {
        products!.removeAt(index);
        setState(() {});
      },
    );
  }

  Future<void> navigateToAddProduct() async {
    //Navigator.pushNamed(context, AddProductScreen.routeName);
    final newProduct =
        await Navigator.pushNamed(context, AddProductScreen.routeName);
    if (newProduct != null && newProduct is Product) {
      setState(() {
        products!.insert(0, newProduct); // Add it at the top of the list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return products == null
        ? Loader()
        : Scaffold(
            body: GridView.builder(
              itemCount: products!.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                final productData = products![index];
                return Column(
                  children: [
                    SizedBox(
                      height: 140,
                      child: SingleProduct(
                        //image: productData.images[0],
                        image: productData.images.isNotEmpty
                            ? productData.images[0]
                            : 'https://via.placeholder.com/150',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Text(
                            productData.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        IconButton(
                          onPressed: () => deleteProduct(productData, index),
                          icon: const Icon(
                            Icons.delete_outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              tooltip: 'Add a Product',
              onPressed: navigateToAddProduct,
              child: Icon(Icons.add),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }
}
