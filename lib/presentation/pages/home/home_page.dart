import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/stock/antsoup_stock_card.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        controller.unfocusSearch();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refreshData,
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                // 앱바
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  flexibleSpace: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Text(
                          '개미탕',
                          style: AppTextStyles.headline4.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: controller.goToNotifications,
                        ),
                        IconButton(
                          icon: Obx(() => Icon(
                            controller.isDarkMode.value
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          )),
                          onPressed: controller.toggleTheme,
                        ),
                      ],
                    ),
                  ),
                ),

                // 검색바
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: CustomSearchBar(
                      hintText: '종목명, 종목코드를 검색하세요',
                      // onChanged: controller.onSearchChanged,
                      controller: controller.searchController,
                      focusNode: controller.searchFocusNode,
                      onSubmitted: (value) => controller.onSearchSubmitted(), // HomeController는 매개변수 없음
                    ),
                  ),
                ),

                // 로딩 상태
                if (controller.isLoading.value) ...[
                  const SliverToBoxAdapter(
                    child: LoadingWidget(message: '데이터를 불러오는 중...'),
                  ),
                ] else ...[
                  // 펄펄끓는 개미탕 섹션
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('🔥 펄펄끓는 개미탕', ''),
                  ),
                  _buildHotAntSoupList(),

                  // 식어가는 개미탕 섹션
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('❄️ 식어가는 개미탕', ''),
                  ),
                  _buildColdAntSoupList(),

                  // 냉탕온탕 개미탕 섹션
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('🌡️ 냉탕온탕 개미탕', ''),
                  ),
                  _buildMixedAntSoupList(),
                ],

                // 하단 여백
                SliverToBoxAdapter(
                  child: SizedBox(height: 20.h),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText, {VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.headline6.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (actionText.isNotEmpty && onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Text(
                actionText,
                style: AppTextStyles.bodyText2.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 펄펄끓는 개미탕 리스트
  Widget _buildHotAntSoupList() {
    return Obx(() {
      if (controller.hotAntSoupStocks.isEmpty) {
        return SliverToBoxAdapter(
          child: Container(
            height: 100.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: const Center(
              child: Text(
                '데이터가 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final stock = controller.hotAntSoupStocks[index];
            return AntSoupStockCard(
              stockName: stock.name,
              stockCode: stock.code,
              currentPrice: stock.formattedPrice,
              priceChangePercent: stock.formattedChangePercent,
              asi5Avg: stock.formattedAsi5Avg,
              isUp: stock.isUp,
              statusLabel: stock.heatStatus,
              statusColor: _getHeatStatusColor(stock.heatStatus),
              onTap: () => controller.goToStockDetail(stock.code),
            );
          },
          childCount: controller.hotAntSoupStocks.length,
        ),
      );
    });
  }

  // 식어가는 개미탕 리스트
  Widget _buildColdAntSoupList() {
    return Obx(() {
      if (controller.coldAntSoupStocks.isEmpty) {
        return SliverToBoxAdapter(
          child: Container(
            height: 100.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: const Center(
              child: Text(
                '데이터가 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final stock = controller.coldAntSoupStocks[index];
            return AntSoupStockCard(
              stockName: stock.name,
              stockCode: stock.code,
              currentPrice: stock.formattedPrice,
              priceChangePercent: stock.formattedChangePercent,
              asi5Avg: stock.formattedAsi5Avg,
              isUp: stock.isUp,
              statusLabel: stock.coldStatus,
              statusColor: _getColdStatusColor(stock.coldStatus),
              onTap: () => controller.goToStockDetail(stock.code),
            );
          },
          childCount: controller.coldAntSoupStocks.length,
        ),
      );
    });
  }

  // 냉탕온탕 개미탕 리스트
  Widget _buildMixedAntSoupList() {
    return Obx(() {
      if (controller.mixedAntSoupStocks.isEmpty) {
        return SliverToBoxAdapter(
          child: Container(
            height: 100.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: const Center(
              child: Text(
                '데이터가 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final stock = controller.mixedAntSoupStocks[index];
            return AntSoupStockCard(
              stockName: stock.name,
              stockCode: stock.code,
              currentPrice: stock.formattedPrice,
              priceChangePercent: stock.formattedChangePercent,
              asi5Avg: stock.formattedAsi5Avg,
              asi5Diff: stock.formattedAsi5Diff,
              isUp: stock.isUp,
              onTap: () => controller.goToStockDetail(stock.code),
              showDiff: true, // 편차 표시
            );
          },
          childCount: controller.mixedAntSoupStocks.length,
        ),
      );
    });
  }

  // 가열 상태 색상
  Color? _getHeatStatusColor(String? status) {
    if (status == null) return null;
    switch (status) {
      case '사골육수':
        return Colors.red[700];
      case '가열중':
        return Colors.orange[700];
      default:
        return null;
    }
  }

  // 냉각 상태 색상
  Color? _getColdStatusColor(String? status) {
    if (status == null) return null;
    switch (status) {
      case '냉동보관':
        return Colors.blue[700];
      case '냉각중':
        return Colors.cyan[700];
      default:
        return null;
    }
  }
}