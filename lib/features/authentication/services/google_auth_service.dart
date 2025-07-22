import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import '../../../utils/exceptions/firebase_auth_exceptions.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../models/user_model.dart';
import 'firestore_user_service.dart';

class GoogleAuthService extends GetxService {
  static GoogleAuthService get instance => Get.find();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestoreUserService = FirestoreUserService.instance;

  /// 현재 로그인된 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  /// 현재 로그인 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Google 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Google 로그인 프로세스 시작...');

      // Google 로그인 프로세스 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // 사용자가 로그인을 취소함
        print('사용자가 Google 로그인을 취소함');
        return null;
      }

      print('Google 계정 선택 완료: ${googleUser.email}');

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase 인증 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Firebase 인증 시작...');

      // Firebase로 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        print('Firebase 로그인 성공: ${userCredential.user!.uid}');

        // Firestore에 사용자 정보 저장/업데이트
        await _saveOrUpdateUserInFirestore(userCredential.user!);
      }

      return userCredential;

    } on FirebaseAuthException catch (e) {
      print('Firebase 인증 에러: ${e.code}');
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      print('Firebase 에러: ${e.code}');
      throw TFirebaseException(e.code).message;
    } catch (e) {
      print('Google 로그인 에러: $e');
      throw TPlatformException('sign_in_failed').message;
    }
  }

  /// Firestore에 사용자 정보 저장 또는 업데이트
  Future<void> _saveOrUpdateUserInFirestore(User firebaseUser) async {
    try {
      print('Firestore 사용자 정보 처리 시작: ${firebaseUser.uid}');

      // 기존 사용자인지 확인
      final existingUser = await _firestoreUserService.getUser(firebaseUser.uid);

      if (existingUser == null) {
        // 신규 사용자만 생성 (중복 생성 방지)
        print('신규 사용자 - Firestore에 정보 생성');

        final newUser = UserModel.fromSocialAuth(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? '',
          authProvider: SocialAuthProvider.google,
          profilePicture: firebaseUser.photoURL,
          phoneNumber: firebaseUser.phoneNumber,
        );

        await _firestoreUserService.createUser(newUser);
        print('신규 사용자 생성 완료');

      } else {
        // 기존 사용자 - 마지막 로그인 시간만 업데이트
        print('기존 사용자 - 로그인 시간 업데이트');
        await _firestoreUserService.updateLastLogin(firebaseUser.uid);
      }

    } catch (e) {
      print('Firestore 사용자 정보 처리 에러: $e');
      // 에러 발생 시에도 로그인은 계속 진행
    }
  }

  /// 현재 사용자를 UserModel로 변환 (Firestore에서 조회)
  Future<UserModel?> getCurrentUserModel() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      // Firestore에서 사용자 정보 조회
      final userModel = await _firestoreUserService.getUser(user.uid);

      if (userModel != null) {
        return userModel;
      } else {
        // Firestore에 정보가 없다면 Firebase Auth 정보로 생성
        print('Firestore에 사용자 정보 없음 - 새로 생성');
        return UserModel.fromSocialAuth(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          authProvider: SocialAuthProvider.google,
          profilePicture: user.photoURL,
          phoneNumber: user.phoneNumber,
        );
      }
    } catch (e) {
      print('현재 사용자 모델 조회 에러: $e');
      return null;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      print('로그아웃 시작...');

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      print('로그아웃 완료');
    } catch (e) {
      print('로그아웃 에러: $e');
      throw TPlatformException('sign_out_failed').message;
    }
  }

  /// 계정 삭제
  Future<void> deleteAccount() async {
    try {
      print('계정 삭제 시작...');

      final user = _auth.currentUser;
      if (user != null) {
        // Firestore에서 사용자 데이터 삭제
        await _firestoreUserService.deleteUser(user.uid);
        print('Firestore 사용자 데이터 삭제 완료');

        // Firebase Auth에서 계정 삭제
        await user.delete();
        print('Firebase Auth 계정 삭제 완료');

        // Google Sign-In 로그아웃
        await _googleSignIn.signOut();
        print('Google Sign-In 로그아웃 완료');
      }

      print('계정 삭제 완료');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth 계정 삭제 에러: ${e.code}');
      throw TFirebaseAuthException(e.code).message;
    } catch (e) {
      print('계정 삭제 에러: $e');
      throw TPlatformException('account_deletion_failed').message;
    }
  }

  /// 현재 로그인되어 있는지 확인
  bool get isSignedIn => currentUser != null;

  /// 계정 재인증 (계정 삭제나 중요한 작업 전)
  Future<UserCredential?> reauthenticate() async {
    try {
      print('계정 재인증 시작...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('재인증 취소됨');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = _auth.currentUser;
      if (user != null) {
        final result = await user.reauthenticateWithCredential(credential);
        print('재인증 완료');
        return result;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      print('재인증 에러: ${e.code}');
      throw TFirebaseAuthException(e.code).message;
    } catch (e) {
      print('재인증 에러: $e');
      throw TPlatformException('reauthentication_failed').message;
    }
  }

  /// 사용자 프로필 업데이트
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      print('사용자 프로필 업데이트 시작...');

      // Firebase Auth 프로필 업데이트
      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Firestore에도 업데이트
      final updates = <String, dynamic>{};
      if (displayName != null) updates['name'] = displayName;
      if (photoURL != null) updates['profile_picture'] = photoURL;

      if (updates.isNotEmpty) {
        await _firestoreUserService.updateUserField(user.uid, updates);
      }

      print('프로필 업데이트 완료');
    } on FirebaseAuthException catch (e) {
      print('프로필 업데이트 에러: ${e.code}');
      throw TFirebaseAuthException(e.code).message;
    } catch (e) {
      print('프로필 업데이트 에러: $e');
      throw TPlatformException('profile_update_failed').message;
    }
  }

  /// FCM 토큰 업데이트
  Future<void> updateFCMToken(String fcmToken) async {
    try {
      final user = currentUser;
      if (user != null) {
        await _firestoreUserService.updateFCMToken(user.uid, fcmToken);
        print('FCM 토큰 업데이트 완료: ${user.uid}');
      }
    } catch (e) {
      print('FCM 토큰 업데이트 에러: $e');
      // FCM 토큰 업데이트 실패는 치명적이지 않음
    }
  }

  /// 이메일 재전송
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('이메일 인증 재전송 완료');
      }
    } on FirebaseAuthException catch (e) {
      print('이메일 인증 재전송 에러: ${e.code}');
      throw TFirebaseAuthException(e.code).message;
    } catch (e) {
      print('이메일 인증 재전송 에러: $e');
      throw TPlatformException('email_verification_failed').message;
    }
  }

  /// 이메일 인증 상태 새로고침
  Future<void> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        print('사용자 정보 새로고침 완료');
      }
    } catch (e) {
      print('사용자 정보 새로고침 에러: $e');
    }
  }
}