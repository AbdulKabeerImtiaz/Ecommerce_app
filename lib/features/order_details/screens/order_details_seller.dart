import 'package:ecommerce_app_db/common/widgets/custom_button.dart';
import 'package:ecommerce_app_db/constants/global_variables.dart';
import 'package:ecommerce_app_db/features/admin/services/admin_services.dart';
import 'package:ecommerce_app_db/features/search/screens/search_screen.dart';
import 'package:ecommerce_app_db/models/order.dart';
import 'package:ecommerce_app_db/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderDetailsSeller extends StatefulWidget {
  static const String routeName = '/order-details-seller';
  final Order order;
  const OrderDetailsSeller({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsSeller> createState() => _OrderDetailsSellerState();
}

class _OrderDetailsSellerState extends State<OrderDetailsSeller> {
  String orderStatus = '';
  final AdminServices adminServices = AdminServices();

  final List<String> statusSteps = [
    'pending',
    'processing',
    'shipped',
    'delivered'
  ];

  void navigateToSearchScreen(String query) {
    Navigator.pushNamed(context, SearchScreen.routeName, arguments: query);
  }

  @override
  void initState() {
    super.initState();
    orderStatus = widget.order.status;
  }

  int getCurrentStepIndex() {
    return statusSteps.indexOf(orderStatus);
  }

  void changeOrderStatus(int index) {
    final currentIndex = statusSteps.indexOf(orderStatus);
    if (currentIndex < statusSteps.length - 1) {
      final newStatus = statusSteps[currentIndex + 1];

      // Call the service to update the order item status
      // adminServices.updateOrderItemStatus(
      //   context: context,
      //   orderId: widget.order.id, // Pass the order ID to update order items
      //   status: newStatus,  // Pass the current status
      // );

      adminServices.updateOrderItemStatus(
        context: context,
        status: newStatus,
        orderId: widget.order.id,
        productId: widget.order.products[index].id!,
        onSuccess: () {
          setState(() {
            orderStatus = newStatus;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/images/amazon_in.png',
                  width: 120,
                  height: 45,
                  color: Colors.black,
                ),
              ),
              const Text(
                'Admin',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'View order details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Date:      ${DateFormat().format(
                      DateTime.fromMillisecondsSinceEpoch(
                          widget.order.orderedAt),
                    )}'),
                    Text('Order ID:          ${widget.order.id}'),
                    //Text('Order Total:      \$${widget.order.totalPrice}'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Purchase Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ...List.generate(widget.order.products.length, (i) {
                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.network(
                                  widget.order.products[i].images[0],
                                  height: 120,
                                  width: 120,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.order.products[i].name,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Qty: ${widget.order.quantity[i]}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tracking',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black12,
                                ),
                              ),
                              child: Stepper(
                                currentStep: getCurrentStepIndex(),
                                controlsBuilder: (context, details) {
                                  return CustomButton(
                                    text: 'Done',
                                    onTap: () => changeOrderStatus(i),
                                    color: GlobalVariables.secondaryColor,
                                  );
                                },
                                steps: [
                                  Step(
                                    title: const Text('Pending'),
                                    content: const Text(
                                        'Your order has been placed but not processed yet.'),
                                    isActive: getCurrentStepIndex() >= 0,
                                    state: getCurrentStepIndex() > 0
                                        ? StepState.complete
                                        : StepState.indexed,
                                  ),
                                  Step(
                                    title: const Text('Processing'),
                                    content: const Text(
                                        'Your order is being prepared for shipment.'),
                                    isActive: getCurrentStepIndex() >= 1,
                                    state: getCurrentStepIndex() > 1
                                        ? StepState.complete
                                        : StepState.indexed,
                                  ),
                                  Step(
                                    title: const Text('Shipped'),
                                    content: const Text(
                                        'Your order has been shipped.'),
                                    isActive: getCurrentStepIndex() >= 2,
                                    state: getCurrentStepIndex() > 2
                                        ? StepState.complete
                                        : StepState.indexed,
                                  ),
                                  Step(
                                    title: const Text('Delivered'),
                                    content: const Text(
                                        'Your order has been delivered successfully.'),
                                    isActive: getCurrentStepIndex() >= 3,
                                    state: getCurrentStepIndex() >= 3
                                        ? StepState.complete
                                        : StepState.indexed,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





















  //             const SizedBox(height: 10),
  //             const Text(
  //               'Tracking',
  //               style: TextStyle(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             Container(
  //               decoration: BoxDecoration(
  //                 border: Border.all(
  //                   color: Colors.black12,
  //                 ),
  //               ),
  //               child: Stepper(
  //                 currentStep: getCurrentStepIndex(),
  //                 controlsBuilder: (context, details) {
                    
  //                     return CustomButton(
  //                       text: 'Done',
  //                       onTap: () => changeOrderStatus(),
  //                     );
                    
                    
  //                 },
  //                 steps: [
  //                   Step(
  //                           title: const Text('Pending'),
  //                           content: const Text(
  //                             'Your order has been placed but not processed yet.',
  //                           ),
  //                           isActive: getCurrentStepIndex() >= 0,
  //                           state: getCurrentStepIndex() > 0
  //                               ? StepState.complete
  //                               : StepState.indexed,
  //                         ),
  //                         Step(
  //                           title: const Text('Processing'),
  //                           content: const Text(
  //                             'Your order is being prepared for shipment.',
  //                           ),
  //                           isActive: getCurrentStepIndex() >= 1,
  //                           state: getCurrentStepIndex() > 1
  //                               ? StepState.complete
  //                               : StepState.indexed,
  //                         ),
  //                         Step(
  //                           title: const Text('Shipped'),
  //                           content: const Text(
  //                             'Your order has been shipped.',
  //                           ),
  //                           isActive: getCurrentStepIndex() >= 2,
  //                           state: getCurrentStepIndex() > 2
  //                               ? StepState.complete
  //                               : StepState.indexed,
  //                         ),
  //                         Step(
  //                           title: const Text('Delivered'),
  //                           content: const Text(
  //                             'Your order has been delivered successfully.',
  //                           ),
  //                           isActive: getCurrentStepIndex() >= 3,
  //                           state: getCurrentStepIndex() >= 3
  //                               ? StepState.complete
  //                               : StepState.indexed,
  //                         ),

  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
    







    // (Other unchanged code...)

    // return Scaffold(
    //   // (AppBar remains unchanged...)
    //   body: SingleChildScrollView(
    //     child: Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           // (Order details and purchase info...)

    //           const SizedBox(height: 10),
    //           const Text(
    //             'Tracking',
    //             style: TextStyle(
    //               fontSize: 22,
    //               fontWeight: FontWeight.bold,
    //             ),
    //           ),
    //           Container(
    //             decoration: BoxDecoration(
    //               border: Border.all(
    //                 color: Colors.black12,
    //               ),
    //             ),
    //             child: orderStatus == 'cancelled'
    //                 ? const Padding(
    //                     padding: EdgeInsets.all(12.0),
    //                     child: Text(
    //                       'This order was cancelled.',
    //                       style: TextStyle(
    //                         fontSize: 16,
    //                         color: Colors.red,
    //                         fontWeight: FontWeight.bold,
    //                       ),
    //                     ),
    //                   )
    //                 : Stepper(
    //                     currentStep: getCurrentStepIndex(),
    //                     controlsBuilder: (context, details) {
    //                       if (user.type == 'admin') {
    //                         return CustomButton(
    //                           text: 'Done',
    //                           onTap: changeOrderStatus,
    //                         );
    //                       }
    //                       return const SizedBox();
    //                     },
    //                     steps: [
    //                       Step(
    //                         title: const Text('Pending'),
    //                         content: const Text(
    //                           'Your order has been placed but not processed yet.',
    //                         ),
    //                         isActive: getCurrentStepIndex() >= 0,
    //                         state: getCurrentStepIndex() > 0
    //                             ? StepState.complete
    //                             : StepState.indexed,
    //                       ),
    //                       Step(
    //                         title: const Text('Processing'),
    //                         content: const Text(
    //                           'Your order is being prepared for shipment.',
    //                         ),
    //                         isActive: getCurrentStepIndex() >= 1,
    //                         state: getCurrentStepIndex() > 1
    //                             ? StepState.complete
    //                             : StepState.indexed,
    //                       ),
    //                       Step(
    //                         title: const Text('Shipped'),
    //                         content: const Text(
    //                           'Your order has been shipped.',
    //                         ),
    //                         isActive: getCurrentStepIndex() >= 2,
    //                         state: getCurrentStepIndex() > 2
    //                             ? StepState.complete
    //                             : StepState.indexed,
    //                       ),
    //                       Step(
    //                         title: const Text('Delivered'),
    //                         content: const Text(
    //                           'Your order has been delivered successfully.',
    //                         ),
    //                         isActive: getCurrentStepIndex() >= 3,
    //                         state: getCurrentStepIndex() >= 3
    //                             ? StepState.complete
    //                             : StepState.indexed,
    //                       ),
    //                     ],
    //                   ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
   

