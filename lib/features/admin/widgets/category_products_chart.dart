import 'package:charts_flutter_updated/charts_flutter_updated.dart' as charts;
import 'package:ecommerce_app_db/features/admin/models/sales.dart';
import 'package:flutter/material.dart';

class CategoryProductsChart extends StatelessWidget {
  final List<charts.Series<Sales, String>> seriesList;
  const CategoryProductsChart({
    super.key,
    required this.seriesList,
  });

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: true,
    );
  }
}
