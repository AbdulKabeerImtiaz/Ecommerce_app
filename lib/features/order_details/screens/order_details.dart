import 'package:ecommerce_app_db/common/widgets/custom_button.dart';
import 'package:ecommerce_app_db/constants/global_variables.dart';
import 'package:ecommerce_app_db/features/admin/services/admin_services.dart';
import 'package:ecommerce_app_db/features/search/screens/search_screen.dart';
import 'package:ecommerce_app_db/models/order.dart';
import 'package:ecommerce_app_db/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderDetailScreen extends StatefulWidget {
  static const String routeName = '/order-details';
  final Order order;
  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  margin: const EdgeInsets.only(left: 15),
                  child: Material(
                    borderRadius: BorderRadius.circular(7),
                    elevation: 1,
                    child: TextFormField(
                      onFieldSubmitted: navigateToSearchScreen,
                      decoration: InputDecoration(
                        prefixIcon: InkWell(
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.only(
                              left: 6,
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 23,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(top: 10),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                        hintText: 'Search Amazon.in',
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.transparent,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: const Icon(Icons.mic, color: Colors.black, size: 25),
              ),
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
                    Text('Order Total:      \$${widget.order.totalPrice}'),
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
                    for (int i = 0; i < widget.order.products.length; i++)
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                  ],
                ),
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
                    // if (user.type == 'admin') {
                    //   return CustomButton(
                    //     text: 'Done',
                    //     onTap: () => changeOrderStatus(details.currentStep),
                    //   );
                    // }
                    return const SizedBox();
                  },
                  steps: [
                    Step(
                      title: const Text('Pending'),
                      content: const Text(
                        'Your order has been placed but not processed yet.',
                      ),
                      isActive: getCurrentStepIndex() >= 0,
                      state: getCurrentStepIndex() > 0
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Processing'),
                      content: const Text(
                        'Your order is being prepared for shipment.',
                      ),
                      isActive: getCurrentStepIndex() >= 1,
                      state: getCurrentStepIndex() > 1
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Shipped'),
                      content: const Text(
                        'Your order has been shipped.',
                      ),
                      isActive: getCurrentStepIndex() >= 2,
                      state: getCurrentStepIndex() > 2
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Delivered'),
                      content: const Text(
                        'Your order has been delivered successfully.',
                      ),
                      isActive: getCurrentStepIndex() >= 3,
                      state: getCurrentStepIndex() >= 3
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}
