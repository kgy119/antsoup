import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final _storage = const FlutterSecureStorage();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  // Password visibility
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // Terms agreement
  final RxBool agreeToTerms = false.obs;

  // Current user
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Set terms agreement
  void setAgreeToTerms(bool value) {
    agreeToTerms.value = value;
  }

  Future<void> checkLoginStatus() async {
    try {
      final token = await _storage.read(key: 'token');
      final userJson = await _storage.read(key: 'user');

      if (token != null && userJson != null) {
        // Parse stored user data
        final userData = Map<String, dynamic>.from(
            Uri.splitQueryString(userJson)
        );
        currentUser.value = UserModel.fromJson(userData);
        isLoggedIn.value = true;
      } else {
        isLoggedIn.value = false;
      }
    } catch (e) {
      print('Error checking login status: $e');
      isLoggedIn.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      // Input validation
      if (email.trim().isEmpty || password.isEmpty) {
        Get.snackbar(
          'Error',
          'Please fill in all fields.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (!GetUtils.isEmail(email)) {
        Get.snackbar(
          'Error',
          'Please enter a valid email address.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful login with mock user data
      final mockUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'User Name', // This would come from the API
        email: email.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store token and user data
      await _storage.write(key: 'token', value: 'mock_jwt_token_${mockUser.id}');
      await _storage.write(key: 'user', value: mockUser.toJson().toString());

      currentUser.value = mockUser;
      isLoggedIn.value = true;

      Get.snackbar(
        'Success',
        'Welcome back!',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      isLoading.value = true;

      // Input validation
      if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
        Get.snackbar(
          'Error',
          'Please fill in all fields.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (name.trim().length < 2) {
        Get.snackbar(
          'Error',
          'Name must be at least 2 characters long.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (!GetUtils.isEmail(email)) {
        Get.snackbar(
          'Error',
          'Please enter a valid email address.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (password.length < 6) {
        Get.snackbar(
          'Error',
          'Password must be at least 6 characters long.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (!agreeToTerms.value) {
        Get.snackbar(
          'Error',
          'Please agree to the Terms of Service and Privacy Policy.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Create user model for new registration
      final newUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Get.snackbar(
        'Success',
        'Account created successfully! Please sign in.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Reset form state
      agreeToTerms.value = false;
      isPasswordVisible.value = false;
      isConfirmPasswordVisible.value = false;

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registration failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'user');

      currentUser.value = null;
      isLoggedIn.value = false;

      // Reset all states
      isPasswordVisible.value = false;
      isConfirmPasswordVisible.value = false;
      agreeToTerms.value = false;

      Get.snackbar(
        'Success',
        'Logged out successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      if (currentUser.value == null) return;

      isLoading.value = true;

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Update user model
      final updatedUser = currentUser.value!.copyWith(
        name: name,
        bio: bio,
        profileImageUrl: profileImageUrl,
        updatedAt: DateTime.now(),
      );

      // Store updated user data
      await _storage.write(key: 'user', value: updatedUser.toJson().toString());
      currentUser.value = updatedUser;

      Get.snackbar(
        'Success',
        'Profile updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Social login methods (placeholder implementations)
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      // TODO: Implement Google Sign-In
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Info',
        'Google Sign-In will be implemented soon.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google Sign-In failed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithApple() async {
    try {
      isLoading.value = true;
      // TODO: Implement Apple Sign-In
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Info',
        'Apple Sign-In will be implemented soon.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Apple Sign-In failed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}