import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/common/common_widgets.dart';
import 'community_controller.dart';

class CommunityPage extends GetView<CommunityController> {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '커뮤니티'),
      body: const Center(
        child: Text('커뮤니티 페이지'),
      ),
    );
  }
}
