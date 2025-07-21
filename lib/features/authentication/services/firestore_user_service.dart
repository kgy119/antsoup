import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../models/user_model.dart';

/// Firestore 사용자 데이터 관리 서비스
class FirestoreUserService extends GetxService {
  static FirestoreUserService get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 컬렉션 이름
  static const String _usersCollection = 'users';

  /// 사용자 정보를 Firestore에 저장 (신규 가입)
  Future<void> createUser(UserModel user) async {
    try {
      print('Firestore에 새 사용자 생성: ${user.email}');

      // UID를 문서 ID로 사용하여 사용자 데이터 저장
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(user.toCreateJson());

      print('사용자 생성 완료: ${user.uid}');
    } on FirebaseException catch (e) {
      print('Firestore 사용자 생성 실패: ${e.code}');
      throw TFirebaseException(e.code).message;
    } catch (e) {
      print('사용자 생성 중 예외 발생: $e');
      throw TPlatformException('user_creation_failed').message;
    }
  }

  /// UID로 사용자 정보 가져오기
  Future<UserModel?> getUser(String uid) async {
    try {
      print('Firestore에서 사용자 조회: $uid');

      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromJson(doc.data()!);
        print('사용자 조회 완료: ${user.email}');
        return user;
      } else {
        print('사용자를 찾을 수 없음: $uid');
        return null;
      }
    } on FirebaseException catch (e) {
      print('Firestore 사용자 조회 실패: ${e.code}');
      throw TFirebaseException(e.code).message;
    } catch (e) {
      print('사용자 조회 중 예외 발생: $e');
      throw TPlatformException('user_fetch_failed').message;
    }
  }

  /// 사용자 정보 업데이트
  Future<void> updateUser(UserModel user) async {
    try {
      print('Firestore 사용자 정보 업데이트: ${user.email}');

      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .update(user.toJson());

      print('사용자 정보 업데이트 완료: ${user.uid}');
    } on FirebaseException catch (e) {
      print('Firestore 사용자 업데이트 실패: ${e.code}');
      throw TFirebaseException(e.code).message;
    } catch (e) {
      print('사용자 업데이트 중 예외 발생: $e');
      throw TPlatformException('user_update_failed').message;
    }
  }

  /// 특정 필드만 업데이트
  Future<void> updateUserField(String uid, Map<String, dynamic> data) async {
    try {
      print('Firestore 사용자 필드 업데이트: $uid');

      // 업데이트 시간 자동 추가
      data['updated_at'] = DateTime.now().toIso8601String();

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update(data);

      print('사용자 필드 업데이트 완료: $uid');
    } on FirebaseException catch (e) {
      print('Firestore 필드 업데이트 실패: ${e.code}');
      throw TFirebaseException(e.code).message;
    } catch (e) {
      print('필드 업데이트 중 예외 발생: $e');
      throw TPlatformException('field_update_failed').message;
    }
  }

  /// 마지막 로그인 시간 업데이트
  Future<void> updateLastLogin(String uid) async {
    try {
      await updateUserField(uid, {
        'last_login_at': DateTime.now().toIso8601String(),
      });
      print('마지막 로그인 시간 업데이트 완료: $uid');
    } catch (e) {
      print('마지막 로그인 시간 업데이트 실패: $e');
      // 로그인 시간 업데이트 실패는 로그인 자체를 막지 않음
    }
  }

  /// FCM 토큰 업데이트
  Future<void> updateFCMToken(String uid, String fcmToken) async {
    try {
      await updateUserField(uid, {
        'fcm_token': fcmToken,
      });
      print('FCM 토큰 업데이트 완료: $uid');
    } catch (e) {
      print('FCM 토큰 업데이트 실패: $e');
    }
  }

  /// 사용자 존재 여부 확인
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      return doc.exists;
    } on FirebaseException catch (e) {
      print('사용자 존재 여부 확인 실패: ${e.code}');
      throw TFirebaseException(e.code).message;
    } catch (e) {
      print('사용자 존재 여부 확인 중 예외 발생: $e');
      throw TPlatformException('user_existence_check_failed').message;
    }
  }

  /// 사용자 삭제
  Future<void> deleteUser(String uid) async {
    try {
      print('Firestore에서 사용자 삭제: $uid');

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .delete();

      print('사용자 삭제 완료: $uid');
    } on FirebaseException catch (e) {
      print('Firestore 사용자 삭제 실패: ${e.code}');
      throw TFirebaseException(e.code).message;
    } catch (e) {
      print('사용자 삭제 중 예외 발생: $e');
      throw TPlatformException('user_deletion_failed').message;
    }
  }

  /// 이메일로 사용자 검색 (중복 체크 등에 사용)
  Future<List<UserModel>> getUsersByEmail(String email) async {
    try {
      print('이메일로 사용자 검색: $email');

      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .get();

      final users = querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();

      print('이메일 검색 결과: ${users.length}명');
      return users;
    } on FirebaseException catch (e) {
      print('이메일 검색 실패: ${e.code}');
      throw TFirebaseException(e.code).message;
    } catch (e) {
      print('이메일 검색 중 예외 발생: $e');
      throw TPlatformException('email_search_failed').message;
    }
  }

  /// 사용자 계정 활성화/비활성화
  Future<void> toggleUserActiveStatus(String uid, bool isActive) async {
    try {
      await updateUserField(uid, {
        'is_active': isActive,
      });
      print('사용자 활성화 상태 변경: $uid -> $isActive');
    } catch (e) {
      print('사용자 활성화 상태 변경 실패: $e');
      throw e;
    }
  }

  /// 푸시 알림 설정 업데이트
  Future<void> updatePushNotificationSettings(String uid, bool enabled) async {
    try {
      await updateUserField(uid, {
        'push_notifications': enabled,
      });
      print('푸시 알림 설정 업데이트: $uid -> $enabled');
    } catch (e) {
      print('푸시 알림 설정 업데이트 실패: $e');
      throw e;
    }
  }

  /// 사용자 리스트 가져오기 (관리자용)
  Future<List<UserModel>> getAllUsers({int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      print('전체 사용자 조회 실패: ${e.code}');
      throw TFirebaseException(e.code).message;
    } catch (e) {
      print('전체 사용자 조회 중 예외 발생: $e');
      throw TPlatformException('users_fetch_failed').message;
    }
  }

  /// 최근 활성 사용자 수 조회
  Future<int> getActiveUsersCount({int days = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('last_login_at', isGreaterThan: cutoffDate.toIso8601String())
          .where('is_active', isEqualTo: true)
          .get();

      return querySnapshot.docs.length;
    } on FirebaseException catch (e) {
      print('활성 사용자 수 조회 실패: ${e.code}');
      throw TFirebaseException(e.code).message;
    } catch (e) {
      print('활성 사용자 수 조회 중 예외 발생: $e');
      return 0; // 실패 시 0 반환
    }
  }
}