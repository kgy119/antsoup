import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/user_repository.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/loader/loaders.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  // Repository
  final _userRepository = Get.put(UserRepository());

  // Form Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController();

  // Form Key
  final addressFormKey = GlobalKey<FormState>();

  // Loading States
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Addresses List
  final RxList<AddressModel> addresses = <AddressModel>[].obs;

  // Selected Address
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  @override
  void onClose() {
    // Controllers 정리
    nameController.dispose();
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    super.onClose();
  }

  /// 주소 목록 로드
  Future<void> loadAddresses() async {
    try {
      isLoading.value = true;

      final addressList = await _userRepository.getUserAddresses();
      addresses.assignAll(addressList);

      // 기본 주소 설정
      final defaultAddress = addressList.where((addr) => addr.isDefault).firstOrNull;
      if (defaultAddress != null) {
        selectedAddress.value = defaultAddress;
      }

    } catch (e) {
      String errorMessage = '주소 목록을 불러오는 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '주소 로드 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 새 주소 추가
  Future<void> addNewAddress() async {
    try {
      // 폼 유효성 검사
      if (!addressFormKey.currentState!.validate()) return;

      isSaving.value = true;

      final addressData = {
        'name': nameController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'street': streetController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'postal_code': postalCodeController.text.trim(),
        'country': countryController.text.trim(),
        'is_default': addresses.isEmpty ? 1 : 0, // 첫 번째 주소는 자동으로 기본 주소
      };

      final newAddress = await _userRepository.addAddress(addressData);
      addresses.add(newAddress);

      // 첫 번째 주소라면 기본 주소로 설정
      if (addresses.length == 1) {
        selectedAddress.value = newAddress;
      }

      // 폼 초기화
      clearForm();

      TLoaders.successSnacBar(
        title: '주소 추가 완료',
        message: '새 주소가 성공적으로 추가되었습니다.',
      );

      // 이전 화면으로 돌아가기
      Get.back();

    } catch (e) {
      String errorMessage = '주소 추가 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '주소 추가 실패',
        message: errorMessage,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// 주소 업데이트
  Future<void> updateAddress(AddressModel address) async {
    try {
      // 폼 유효성 검사
      if (!addressFormKey.currentState!.validate()) return;

      isSaving.value = true;

      final addressData = {
        'name': nameController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'street': streetController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'postal_code': postalCodeController.text.trim(),
        'country': countryController.text.trim(),
      };

      final updatedAddress = await _userRepository.updateAddress(address.id!, addressData);

      // 리스트에서 주소 업데이트
      final index = addresses.indexWhere((addr) => addr.id == address.id);
      if (index != -1) {
        addresses[index] = updatedAddress;
      }

      // 선택된 주소가 업데이트된 주소라면 갱신
      if (selectedAddress.value?.id == address.id) {
        selectedAddress.value = updatedAddress;
      }

      TLoaders.successSnacBar(
        title: '주소 업데이트 완료',
        message: '주소가 성공적으로 업데이트되었습니다.',
      );

      // 이전 화면으로 돌아가기
      Get.back();

    } catch (e) {
      String errorMessage = '주소 업데이트 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '주소 업데이트 실패',
        message: errorMessage,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// 주소 삭제
  Future<void> deleteAddress(AddressModel address) async {
    try {
      // 확인 다이얼로그
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('주소 삭제'),
          content: const Text('이 주소를 삭제하시겠습니까?\n삭제된 주소는 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (result != true) return;

      isLoading.value = true;

      await _userRepository.deleteAddress(address.id!);

      // 리스트에서 주소 제거
      addresses.removeWhere((addr) => addr.id == address.id);

      // 삭제된 주소가 선택된 주소였다면 초기화
      if (selectedAddress.value?.id == address.id) {
        selectedAddress.value = addresses.isNotEmpty ? addresses.first : null;
      }

      TLoaders.successSnacBar(
        title: '주소 삭제 완료',
        message: '주소가 성공적으로 삭제되었습니다.',
      );

    } catch (e) {
      String errorMessage = '주소 삭제 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '주소 삭제 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 기본 주소 설정
  Future<void> setDefaultAddress(AddressModel address) async {
    try {
      isLoading.value = true;

      await _userRepository.setDefaultAddress(address.id!);

      // 모든 주소의 기본 설정을 false로 변경
      for (int i = 0; i < addresses.length; i++) {
        addresses[i] = addresses[i].copyWith(isDefault: false);
      }

      // 선택된 주소만 기본 주소로 설정
      final index = addresses.indexWhere((addr) => addr.id == address.id);
      if (index != -1) {
        addresses[index] = addresses[index].copyWith(isDefault: true);
        selectedAddress.value = addresses[index];
      }

      TLoaders.successSnacBar(
        title: '기본 주소 설정',
        message: '기본 주소가 변경되었습니다.',
      );

    } catch (e) {
      String errorMessage = '기본 주소 설정 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '기본 주소 설정 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 주소 선택
  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
  }

  /// 주소 편집을 위해 폼에 데이터 설정
  void populateForm(AddressModel address) {
    nameController.text = address.name;
    phoneController.text = address.phoneNumber;
    streetController.text = address.street;
    cityController.text = address.city;
    stateController.text = address.state;
    postalCodeController.text = address.postalCode;
    countryController.text = address.country;
  }

  /// 폼 초기화
  void clearForm() {
    nameController.clear();
    phoneController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    countryController.clear();
  }

  /// 주소 목록 새로고침
  Future<void> refreshAddresses() async {
    await loadAddresses();
  }

  /// 유효성 검사 메서드들
  String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return '이름을 입력해주세요.';
    }
    if (name.length < 2) {
      return '이름은 2자 이상이어야 합니다.';
    }
    return null;
  }

  String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return '전화번호를 입력해주세요.';
    }
    final phoneRegExp = RegExp(r'^[0-9-+\s()]+$');
    if (!phoneRegExp.hasMatch(phoneNumber)) {
      return '올바른 전화번호 형식이 아닙니다.';
    }
    return null;
  }

  String? validateStreet(String? street) {
    if (street == null || street.isEmpty) {
      return '도로명/지번을 입력해주세요.';
    }
    if (street.length < 5) {
      return '상세 주소를 입력해주세요.';
    }
    return null;
  }

  String? validateCity(String? city) {
    if (city == null || city.isEmpty) {
      return '시/군/구를 입력해주세요.';
    }
    return null;
  }

  String? validateState(String? state) {
    if (state == null || state.isEmpty) {
      return '시/도를 입력해주세요.';
    }
    return null;
  }

  String? validatePostalCode(String? postalCode) {
    if (postalCode == null || postalCode.isEmpty) {
      return '우편번호를 입력해주세요.';
    }
    final postalRegExp = RegExp(r'^[0-9]{5}$');
    if (!postalRegExp.hasMatch(postalCode)) {
      return '올바른 우편번호 형식이 아닙니다. (5자리 숫자)';
    }
    return null;
  }

  String? validateCountry(String? country) {
    if (country == null || country.isEmpty) {
      return '국가를 입력해주세요.';
    }
    return null;
  }

  /// 기본 주소 가져오기
  AddressModel? get defaultAddress {
    return addresses.where((addr) => addr.isDefault).firstOrNull;
  }

  /// 주소 개수
  int get addressCount => addresses.length;

  /// 주소가 있는지 확인
  bool get hasAddresses => addresses.isNotEmpty;
}