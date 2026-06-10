// //flutter
// import 'dart:async';
// //packages
// import 'package:get/get.dart';
// //controllers
// //views
// import 'package:omkar_app/view/otp/phone_auth.dart';
// import 'package:omkar_app/controller/networkController.dart';
// import 'package:omkar_app/models/customerModel.dart';
// import 'package:omkar_app/view/dashboard/dashboardScreen.dart';
// import 'package:omkar_app/view/otp/registrationScreen.dart';
//
// import '../utils/sharedPrefs.dart';
//
// class SplashController extends GetxController {
//   NetworkController networkController = Get.put(NetworkController());
//   SharedHelper helper = SharedHelper();
//
//   @override
//   void onInit() async {
//     _init();
//     super.onInit();
//   }
//
//   @override
//   void onClose() {
//     super.onClose();
//   }
//
//
//   _init() async {
//     CustomerModel? customerModel = await helper.getCustomer();
//     Timer(Duration(seconds: 3), () {
//       Get.off(
//         () =>
//         customerModel == null
//             ? LoginScreen()
//             : DashboardScreen(pageIndex: 0),
//             // // customerModel == null
//             //      RegistrationScreen()
//       );
//     });
//   }
// }
//

import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omkar_app/constant/app_constant.dart';
import 'package:omkar_app/models/settingModel.dart';

import '../constant/api_endpoints.dart';
import '../models/firmModel.dart';
import '../utils/services/api_services.dart';
import '../utils/sharedPrefs.dart';
import 'networkController.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController controller;
  late AnimationController? popUpAnimationController;
  late Animation<double>? animation2;
  NetworkController networkController = Get.put(NetworkController());
  SharedHelper helper = SharedHelper();
  List<FirmInfo> firmList = [];
  List<SettingInfo> settingList = [];
  RxBool isLoading = false.obs;
  RxString checkException = "".obs;
  RxBool hasInternet = true.obs;

  RxDouble size = 50.0.obs;
  RxString savedReferMessage = ''.obs;
  RxString savedReferTitle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getFirm();
    getSettingData();
    controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();

    popUpAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    animation2 = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    Future.delayed(const Duration(milliseconds: 150), onChangeSize);
  }

  void onChangeSize() {
    size.value = 200;
    popUpAnimationController?.forward();
  }

  // /// Save Firm ID
  // Future<void> saveFirmId(String firmId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(_fir, firmId);
  // }

  /// Get Firm ID
  Future<String?> getFirmId() async {
    return helper.getStoredString("firmIdKey");
  }

  /// Get Firm all data
  Future<void> getFirm() async {
    try {
      isLoading.value = true;
      update();

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        hasInternet.value = false;
        checkException.value = "No Internet Connection";
        return;
      } else {
        hasInternet.value = true;
      }

      var response = await ApiService.get(get_firms);

      if (response.data['IsSuccess'] == true) {
        FirmModel firmModel = FirmModel.fromJson(response.data);

        if (firmModel.data != null && firmModel.data!.isNotEmpty) {
          firmList = firmModel.data!;
        }

        isLoading.value = false;
        update();
      } else {
        print(response.data['Message']);
        // throw Exception("Error from API: ${response.data['Message']}");
      }
    } catch (e) {
      String errorMessage = e.toString();
      debugPrint("Error in getFirm: $errorMessage");

      if (errorMessage.contains("receiveTimeout") ||
          errorMessage.contains("SocketException") ||
          errorMessage.contains("Network Error") ||
          errorMessage.contains("Connection failed") ||
          errorMessage.contains("aborted") ||
          errorMessage.contains("Failed host lookup")) {
        checkException.value = "Network Error";
      } else {
        checkException.value = errorMessage;
      }

      // getFlutterToast(checkException.value, Colors.red);
      update();
    }
  }

  /// Get Setting all data
  Future<void> getSettingData() async {
    try {
      isLoading.value = true;
      update();

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        hasInternet.value = false;
        checkException.value = "No Internet Connection";
        getFlutterToast(checkException.value, Colors.red);
        return;
      } else {
        hasInternet.value = true;
      }

      final response = await ApiService.get(getSetting);
      debugPrint("API Setting Response: ${response.data}");

      if (response.data['IsSuccess'] == true) {
        SettingModel settingModel = SettingModel.fromJson(response.data);

        if (settingModel.data != null && settingModel.data!.isNotEmpty) {
          settingList.assignAll(settingModel.data!);
          SettingInfo settingInfo = settingModel.data![0];

          String referMessage = await settingInfo.referMessageLocalized;
          String referTitle = await settingInfo.referTitleLocalized;

          await helper.storeString("savedReferMessage", referMessage);
          await helper.storeString("savedReferTitle", referTitle);

          savedReferMessage.value = referMessage;
          savedReferTitle.value = referTitle;
        } else {
          log("No data in SettingModel: ${settingModel.message}");
          checkException.value = "No settings data available";
        }
      } else {
        checkException.value = response.data['Message'] ?? "Unknown error";
        getFlutterToast(checkException.value, Colors.red);
      }
    } catch (e, stackTrace) {
      String errorMessage = e.toString();
      log("Error in getSettingData: $errorMessage, StackTrace: $stackTrace");

      if (errorMessage.contains("receiveTimeout") ||
          errorMessage.contains("SocketException") ||
          errorMessage.contains("Network Error") ||
          errorMessage.contains("Connection failed") ||
          errorMessage.contains("aborted") ||
          errorMessage.contains("Failed host lookup")) {
        checkException.value = "Network Error";
      } else {
        checkException.value = errorMessage;
      }
      print("======== check Exception ${checkException.value}");
      // getFlutterToast(checkException.value, Colors.red);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  @override
  void onClose() {
    controller.dispose();
    popUpAnimationController?.dispose();
    super.onClose();
  }
}
