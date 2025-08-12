import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/common/common_widgets.dart';
import 'stock_controller.dart';

class StockPage extends GetView<StockController> {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '종목'),
      body: const Center(
        child: Text('종목 페이지'),
      ),
    );
  }
}