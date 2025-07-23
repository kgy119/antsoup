import 'package:antsoup/common/widgets/appbar/appbar.dart';
import 'package:antsoup/common/widgets/appbar/tabbar.dart';
import 'package:antsoup/common/widgets/custom_shapes/contaioners/search_container.dart';
import 'package:antsoup/common/widgets/list_tiles/user_list_tile.dart';
import 'package:antsoup/features/stock/controllers/message_controller.dart';
import 'package:antsoup/utils/constants/colors.dart';
import 'package:antsoup/utils/constants/sizes.dart';
import 'package:antsoup/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const TAppBar(
          title: Text('메시지'),
          showBackArrow: false,
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                backgroundColor: dark ? TColors.black : TColors.white,
                expandedHeight: 0,
                flexibleSpace: TTabBar(
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.people),
                          SizedBox(width: 8),
                          Text('사용자'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.message),
                          SizedBox(width: 8),
                          Text('채팅방'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              UserListTab(),
              ChatRoomListTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// 사용자 리스트 탭
class UserListTab extends StatelessWidget {
  const UserListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageController());

    return Column(
      children: [
        /// 검색 컨테이너
        Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: TSearchContaioner(
            text: '사용자 검색...',
            onTab: () => _showSearchDialog(context, controller),
          ),
        ),

        /// 사용자 리스트
        Expanded(
          child: Obx(() {
            if (controller.isLoadingUsers.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.filteredUsers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.people,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.searchQuery.value.isEmpty
                          ? '등록된 사용자가 없습니다'
                          : '검색 결과가 없습니다',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    if (controller.searchQuery.value.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => controller.searchUsers(''),
                        child: const Text('전체 보기'),
                      ),
                    ],
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshUserList,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
                itemCount: controller.filteredUsers.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  indent: TSizes.defaultSpace + 50,
                  endIndent: TSizes.defaultSpace,
                ),
                itemBuilder: (context, index) {
                  final user = controller.filteredUsers[index];
                  return TUserListTile(
                    user: user,
                    onTap: () => controller.showChatDialog(user),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  /// 검색 다이얼로그
  void _showSearchDialog(BuildContext context, MessageController controller) {
    showDialog(
      context: context,
      builder: (context) {
        final searchController = TextEditingController();

        return AlertDialog(
          title: const Text('사용자 검색'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: '이름 또는 이메일 입력',
              prefixIcon: Icon(Iconsax.search_normal),
            ),
            onChanged: (value) => controller.searchUsers(value),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.searchUsers('');
                Navigator.pop(context);
              },
              child: const Text('전체 보기'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}

// 임시 채팅방 리스트 탭
class ChatRoomListTab extends StatelessWidget {
  const ChatRoomListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.message, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '채팅방 리스트',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '곧 구현될 예정입니다',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}