import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:antsoup/utils/loader/loaders.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final Rx<ConnectivityResult> _connectionStatus = ConnectivityResult.none.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .map((results) => results.isNotEmpty ? results.first : ConnectivityResult.none)
        .listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _connectionStatus.value = result;
    if(_connectionStatus.value == ConnectivityResult.none){
      TLoaders.warningSnacBar(title: 'No Internet Connection');
    }
  }

  Future<bool> isConnected() async {
    try{
      final result = await _connectivity.checkConnectivity();
      if(result == ConnectivityResult.none){
        return false;
      }else{
        return true;
      }
    } on PlatformException catch (_) {
      return false;
    }
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    _connectivitySubscription.cancel();
  }
}