import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/common/common_widgets.dart';
import 'chart_controller.dart';

class ChartPage extends GetView<ChartController> {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '차트'),
      body: const Center(
        child: Text('차트 페이지'),
      ),
    );
  }
}
