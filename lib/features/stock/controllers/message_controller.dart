import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widgets/images/t_circular_image.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../authentication/models/user_model.dart';
import '../../authentication/services/firestore_user_service.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../../utils/loader/loaders.dart';

class MessageController extends GetxController {
  static MessageController get instance => Get.find();

  final _firestoreUserService = FirestoreUserService.instance;

  // 사용자 리스트
  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;

  // 로딩 상태
  final RxBool isLoadingUsers = false.obs;

  // 검색 관련
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllUsers();
  }

  /// 모든 사용자 로드
  Future<void> loadAllUsers() async {
    try {
      isLoadingUsers.value = true;
      print('사용자 리스트 로드 시작...');

      final users = await _firestoreUserService.getAllUsers(limit: 100);

      // 현재 로그인한 사용자 제외
      String? currentUserId;
      try {
        final authController = AuthController.instance;
        currentUserId = authController.currentUser.value?.uid;
      } catch (e) {
        print('AuthController를 찾을 수 없음: $e');
        // AuthController가 없어도 전체 사용자 목록은 표시
      }

      final otherUsers = currentUserId != null
          ? users.where((user) => user.uid != currentUserId).toList()
          : users;

      allUsers.value = otherUsers;
      filteredUsers.value = otherUsers;

      print('사용자 리스트 로드 완료: ${otherUsers.length}명');
    } catch (e) {
      print('사용자 리스트 로드 실패: $e');
      TLoaders.errorSnacBar(
        title: '로드 실패',
        message: '사용자 목록을 불러오는데 실패했습니다.',
      );
    } finally {
      isLoadingUsers.value = false;
    }
  }

  /// 사용자 검색
  void searchUsers(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredUsers.value = allUsers;
    } else {
      filteredUsers.value = allUsers.where((user) {
        return user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  /// 사용자 리스트 새로고침
  Future<void> refreshUserList() async {
    await loadAllUsers();
  }

  /// 사용자와의 채팅 시작
  void startChatWithUser(UserModel user) {
    // TODO: 다음 단계에서 구현
    print('${user.name}과의 채팅 시작');
    TLoaders.infoSnacBar(
      title: '채팅',
      message: '${user.name}님과의 채팅 기능은 곧 구현될 예정입니다.',
    );
  }

  /// 현재 로그인한 사용자 UID 가져오기 (안전한 방법)
  String? get currentUserUid {
    try {
      if (Get.isRegistered<AuthController>()) {
        return AuthController.instance.currentUser.value?.uid;
      }
      return null;
    } catch (e) {
      print('현재 사용자 UID 조회 실패: $e');
      return null;
    }
  }

  /// 채팅 확인 다이얼로그 표시
  void showChatDialog(UserModel user) {
    final dark = THelperFunctions.isDarkMode(Get.context!);

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            TCircularImage(
              image: user.profilePicture ?? 'assets/images/content/user.png',
              isNetworkImage: user.hasProfilePicture,
              width: 40,
              height: 40,
              padding: 0,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user.name,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          '${user.name}님과 채팅을 시작하시겠습니까?',
          style: Get.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '취소',
              style: TextStyle(
                color: dark ? TColors.darkGrey : TColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              startChatWithUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('채팅'),
          ),
        ],
      ),
    );
  }
}