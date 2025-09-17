import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/constants/app_constants.dart';
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
            child: Obx(() {
              // 초기 로딩 상태일 때 전체 화면 로딩 표시
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 3.0,
                      ),
                      SizedBox(height: 24.h),

                      // AppConstants에서 랜덤 로딩 메시지 가져오기
                      Text(
                        AppConstants.getRandomLoadingMessage(),
                        style: AppTextStyles.bodyText1.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        '잠시만 기다려 주세요',
                        style: AppTextStyles.bodyText2.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }


              // 로딩이 완료된 후 정상 컨텐츠 표시
              return CustomScrollView(
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
                          SizedBox(width: 8.w),

                          // 실시간 데이터 상태 표시
                          GetBuilder<HomeController>(
                            builder: (controller) {
                              if (controller.hasNaverData) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4.r),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 6.w,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'LIVE',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Container();
                            },
                          ),
                          const Spacer(),

                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: controller.goToNotifications,
                          ),

                          // 테마 토글 버튼
                          GetBuilder<HomeController>(
                            id: 'themeMode',
                            builder: (controller) => IconButton(
                              icon: Icon(
                                controller.isDarkMode.value
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                              ),
                              onPressed: controller.toggleTheme,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 나머지 슬리버들...
                  // 에러 상태 표시
                  GetBuilder<HomeController>(
                    id: 'error',
                    builder: (controller) {
                      if (controller.hasError.value) {
                        return SliverToBoxAdapter(
                          child: Container(
                            height: 200.h,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48.sp,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    controller.errorMessage.value,
                                    style: AppTextStyles.bodyText1,
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16.h),
                                  ElevatedButton(
                                    onPressed: controller.refreshData,
                                    child: const Text('다시 시도'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),

                  // 식어가는 개미탕 섹션
                  _buildSectionHeader(
                    '식어가는 개미탕 🧊',
                    '',
                        () {},
                  ),
                  _buildColdAntSoupList(),

                  // 냉탕온탕 개미탕 섹션
                  _buildSectionHeader(
                    '냉탕온탕 개미탕 🌊',
                    '',
                        () {},
                  ),
                  _buildMixedAntSoupList(),

                  // 펄펄끓는 개미탕 섹션
                  _buildSectionHeader(
                    '펄펄끓는 개미탕 🔥',
                    '',
                        () {},
                  ),
                  _buildHotAntSoupList(),

                  // 하단 여백
                  SliverToBoxAdapter(
                    child: SizedBox(height: 20.h),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // 섹션 헤더 (단순 제목만 표시)
  Widget _buildSectionHeader(String title, String actionText, VoidCallback? onTap, {String? sectionType}) {
    return SliverToBoxAdapter(
      child: Padding(
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
      ),
    );
  }

  // 펄펄끓는 개미탕 리스트
  Widget _buildHotAntSoupList() {
    return GetBuilder<HomeController>(
      id: 'hotAntSoupStocks',
      builder: (controller) {
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
                currentPrice: stock.hasNaverData ? stock.formattedDisplayPrice : stock.formattedPrice,
                priceChangeAmount: stock.formattedDisplayChangeAmount,
                priceChangePercent: stock.formattedDisplayChangePercent,
                asi5Avg: stock.formattedCurrentAsi,
                asiWithChange1: stock.formattedAsiWithChange1,
                asiWithChange3: stock.formattedAsiWithChange3,
                asiWithChange7: stock.formattedAsiWithChange7,
                isUp: stock.hasNaverData ? stock.isDisplayUp : stock.isUp,
                isAsiUp1: stock.isAsiUp1,
                isAsiUp3: stock.isAsiUp3,
                isAsiUp7: stock.isAsiUp7,
                hasLiveData: stock.hasNaverData,
                statusLabel: stock.heatStatus,  // 추가
                statusColor: _getHeatStatusColor(stock.heatStatus),  // 추가
                onTap: () => controller.goToStockDetail(stock.code),
              );
            },
            childCount: controller.hotAntSoupStocks.length,
          ),
        );
      },
    );
  }

// _buildColdAntSoupList() 메서드 수정
  Widget _buildColdAntSoupList() {
    return GetBuilder<HomeController>(
      id: 'coldAntSoupStocks',
      builder: (controller) {
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
                currentPrice: stock.hasNaverData ? stock.formattedDisplayPrice : stock.formattedPrice,
                priceChangeAmount: stock.formattedDisplayChangeAmount,
                priceChangePercent: stock.formattedDisplayChangePercent,
                asi5Avg: stock.formattedCurrentAsi,
                asiWithChange1: stock.formattedAsiWithChange1,
                asiWithChange3: stock.formattedAsiWithChange3,
                asiWithChange7: stock.formattedAsiWithChange7,
                isUp: stock.hasNaverData ? stock.isDisplayUp : stock.isUp,
                isAsiUp1: stock.isAsiUp1,
                isAsiUp3: stock.isAsiUp3,
                isAsiUp7: stock.isAsiUp7,
                hasLiveData: stock.hasNaverData,
                statusLabel: stock.coldStatus,  // 추가
                statusColor: _getColdStatusColor(stock.coldStatus),  // 추가
                onTap: () => controller.goToStockDetail(stock.code),
              );
            },
            childCount: controller.coldAntSoupStocks.length,
          ),
        );
      },
    );
  }

// _buildMixedAntSoupList() 메서드 수정
  Widget _buildMixedAntSoupList() {
    return GetBuilder<HomeController>(
      id: 'mixedAntSoupStocks',
      builder: (controller) {
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
              // 혼합탕에서는 가열/냉각 상태를 모두 확인해서 표시
              final heatStatus = stock.heatStatus;
              final coldStatus = stock.coldStatus;
              final statusLabel = heatStatus ?? coldStatus;
              final statusColor = heatStatus != null
                  ? _getHeatStatusColor(heatStatus)
                  : _getColdStatusColor(coldStatus);

              return AntSoupStockCard(
                stockName: stock.name,
                stockCode: stock.code,
                currentPrice: stock.hasNaverData ? stock.formattedDisplayPrice : stock.formattedPrice,
                priceChangeAmount: stock.formattedDisplayChangeAmount,
                priceChangePercent: stock.formattedDisplayChangePercent,
                asi5Avg: stock.formattedCurrentAsi,
                asiWithChange1: stock.formattedAsiWithChange1,
                asiWithChange3: stock.formattedAsiWithChange3,
                asiWithChange7: stock.formattedAsiWithChange7,
                isUp: stock.hasNaverData ? stock.isDisplayUp : stock.isUp,
                isAsiUp1: stock.isAsiUp1,
                isAsiUp3: stock.isAsiUp3,
                isAsiUp7: stock.isAsiUp7,
                hasLiveData: stock.hasNaverData,
                statusLabel: statusLabel,  // 추가
                statusColor: statusColor,  // 추가
                onTap: () => controller.goToStockDetail(stock.code),
              );
            },
            childCount: controller.mixedAntSoupStocks.length,
          ),
        );
      },
    );
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