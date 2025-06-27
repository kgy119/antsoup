// lib/features/authentication/services/google_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import '../../../utils/exceptions/firebase_auth_exceptions.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../models/user_model.dart';

class GoogleAuthService extends GetxService {
  static GoogleAuthService get instance => Get.find();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 현재 로그인된 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  /// 현재 로그인 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Google 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Google 로그인 프로세스 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // 사용자가 로그인을 취소함
        return null;
      }

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase 인증 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase로 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      return userCredential;

    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } catch (e) {
      throw TPlatformException('sign_in_failed').message;
    }
  }

  /// 현재 사용자를 UserModel로 변환
  UserModel? getCurrentUserModel() {
    final user = currentUser;
    if (user == null) return null;

    return UserModel.fromSocialAuth(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      authProvider: SocialAuthProvider.google, // 수정된 enum 사용
      profilePicture: user.photoURL,
      phoneNumber: user.phoneNumber,
    );
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw TPlatformException('sign_out_failed').message;
    }
  }

  /// 계정 삭제
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        await _googleSignIn.signOut();
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } catch (e) {
      throw TPlatformException('account_deletion_failed').message;
    }
  }

  /// 현재 로그인되어 있는지 확인
  bool get isSignedIn => currentUser != null;

  /// 계정 재인증 (계정 삭제나 중요한 작업 전)
  Future<UserCredential?> reauthenticate() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = _auth.currentUser;
      if (user != null) {
        return await user.reauthenticateWithCredential(credential);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } catch (e) {
      throw TPlatformException('reauthentication_failed').message;
    }
  }
}