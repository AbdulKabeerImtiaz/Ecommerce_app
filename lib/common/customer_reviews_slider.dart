import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app_db/models/product.dart';
import 'package:ecommerce_app_db/models/rating.dart';
import 'package:intl/intl.dart';

class CustomerReviewsSlider extends StatelessWidget {
  final Product product;

  const CustomerReviewsSlider({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    String formatDate(String dateString) {
      // print('here');
      // print(dateString);
      try {
        // Replace the space with 'T' for proper parsing.
        DateTime date = DateTime.parse(dateString);
        // Use intl to format the date as '8 May 2024'
        return DateFormat('d MMMM yyyy').format(date);
      } catch (e) {
        print("Error parsing date: $e");
        return 'Invalid date';
      }
    }

    //print(product.rating);
    if (product.rating == null || product.rating!.isEmpty) {
      return const Center(
        child: Text('No reviews yet!', style: TextStyle(fontSize: 16)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Reviews',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
            enlargeCenterPage: true,
            autoPlay: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.8,
          ),
          items: product.rating!.map((Rating rating) {
            return Builder(
              builder: (BuildContext context) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < rating.rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          rating.comment,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Reviewed on: ${formatDate(rating.createdAt)}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
