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
import 'package:omkar_app/constant/colorConst.dart';
import 'package:omkar_app/models/settingModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/api_endpoints.dart';
import '../models/customerModel.dart';
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
    // try {
    //   isLoading.value = false;
    //   update();

    //   final connectivityResult = await Connectivity().checkConnectivity();
    //   if (connectivityResult == ConnectivityResult.none) {
    //     hasInternet.value = false;
    //     checkException.value = "No Internet Connection";
    //     return;
    //   } else {
    //     hasInternet.value = true;
    //   }
    //   print("Api for get_firm ${ApiService.baseUrl + get_firms}");
    //   var response = await ApiService.get(get_firms);

    //   print("Api Data getFirms Data ${response.data}");
    //   if (response.data['IsSuccess'] == true) {
    //     print("API Response: ${response.data}");

    //     FirmModel firmModel = FirmModel.fromJson(response.data);

    //     if (firmModel.data != null && firmModel.data!.isNotEmpty) {
    //       firmList = firmModel.data!;

    //       // String firmId = firmList[0].firmId ?? '';
    //       // await helper.storeString("firmIdKey", firmId);
    //       // print("Saved firm ID: $firmId");
    //     }

    //     isLoading.value = false;
    //     update();
    //   } else {
    //     throw Exception("Error from API: ${response.data['Message']}");
    //   }
    // } catch (e) {
    //   String errorMessage = e.toString();
    //   print("error $errorMessage");

    //   if (errorMessage.contains("receiveTimeout") ||
    //       errorMessage.contains("SocketException") ||
    //       errorMessage.contains("Network Error") ||
    //       errorMessage.contains("Connection failed") ||
    //       errorMessage.contains("aborted") ||
    //       errorMessage.contains("Failed host lookup")) {
    //     checkException.value = "Network Error";
    //     update();
    //   } else {
    //     checkException.value = errorMessage;
    //     update();
    //   }

    //   getFlutterToast(checkException.value, Colors.red);
    //   print("Error in getFirmData: $errorMessage");

    //   throw Exception("Failed to get firm data: $errorMessage");
    //   // checkException.value = e..toString();
    //   // print("Error in getFirmData: $e");
    //   //
    //   // throw Exception("Failed to get firm data: $e");
    // }
  }

  /// Get Setting all data
  Future<void> getSettingData() async {
    // try {
    //   isLoading.value = true;
    //   update();

    //   final connectivityResult = await Connectivity().checkConnectivity();
    //   if (connectivityResult == ConnectivityResult.none) {
    //     hasInternet.value = false;
    //     checkException.value = "No Internet Connection";
    //     getFlutterToast(checkException.value, Colors.red);
    //     return;
    //   } else {
    //     hasInternet.value = true;
    //   }

    //   final response = await ApiService.get(getSetting);
    //   log("API  Setting Response: ${response.data}");

    //   if (response.data['IsSuccess'] == true) {
    //     String? languageName = await helper.getStoredString(
    //       "languageNameFinal",
    //     );
    //     print("===========> Splash Screen Language Name ${languageName}");
    //     SettingModel settingModel = SettingModel.fromJson(response.data);

    //     if (settingModel.data != null && settingModel.data!.isNotEmpty) {
    //       settingList.assignAll(settingModel.data!);
    //       SettingInfo settingInfo = settingModel.data![0];
    //       print("==========> Setting Image ${settingInfo.referImage}");
    //       String referMessage = await settingInfo.referMessageLocalized;
    //       String referTitle = await settingInfo.referTitleLocalized;
    //       await helper.storeString("savedReferMessage", referMessage);
    //       await helper.storeString("savedReferTitle", referTitle);
    //       savedReferMessage.value = referMessage;
    //       savedReferTitle.value = referTitle;
    //     } else {
    //       log("No data in SettingModel: ${settingModel.message}");
    //       checkException.value = "No settings data available";
    //       getFlutterToast(checkException.value, Colors.orange);
    //     }
    //   } else {
    //     checkException.value = response.data['Message'] ?? "Unknown error";
    //     getFlutterToast(checkException.value, Colors.red);
    //     throw Exception("Error from API: ${checkException.value}");
    //   }
    // } catch (e, stackTrace) {
    //   String errorMessage = e.toString();
    //   log("Error in getSettingData: $errorMessage, StackTrace: $stackTrace");

    //   if (errorMessage.contains("receiveTimeout") ||
    //       errorMessage.contains("SocketException") ||
    //       errorMessage.contains("Network Error") ||
    //       errorMessage.contains("Connection failed") ||
    //       errorMessage.contains("aborted") ||
    //       errorMessage.contains("Failed host lookup")) {
    //     checkException.value = "Network Error";
    //   } else {
    //     checkException.value = errorMessage;
    //   }
    //   getFlutterToast(checkException.value, Colors.red);

    //   throw Exception("Failed to get setting data: $errorMessage");
    // } finally {
    //   isLoading.value = false;
    //   update();
    // }
  }

  @override
  void onClose() {
    controller.dispose();
    popUpAnimationController?.dispose();
    super.onClose();
  }
}
