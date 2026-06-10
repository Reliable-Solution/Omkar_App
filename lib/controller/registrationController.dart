import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omkar_app/constant/app_constant.dart';
import '../utils/sharedPrefs.dart';
import 'authController.dart';
import 'homeController.dart';

class RegistrationController extends GetxController {
  // Observables for data persistence across views
  final name = ''.obs;
  final email = ''.obs;
  final refer = ''.obs;
  final phoneNumber = ''.obs;
  // Controllers for UI input
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final referController = TextEditingController();

  final isPhoneNumberValid = false.obs;
  var isLoading = false.obs;

  late final AuthController authController;
  late final HomeController homeController;
  SharedHelper helper = SharedHelper();

  @override
  void onInit() {
    super.onInit();
    // Find existing AuthController instead of creating new one
    authController = Get.find<AuthController>();
    // Find HomeController lazily
    homeController = Get.find<HomeController>();
    // Sync controllers with observables if needed
    nameController.addListener(() => name.value = nameController.text);
    phoneController.addListener(() => phoneNumber.value = phoneController.text);
    referController.addListener(() => refer.value = referController.text);
  }

  void setPhoneNumber(String value) {
    phoneController.text = value;
    phoneNumber.value = value;
    isPhoneNumberValid.value = value.length == 10;
    update();
  }

  void setName(String value) {
    nameController.text = value;
    name.value = value;
  }

  void setRefer(String value) {
    referController.text = value;
    refer.value = value;
  }

  void submitRegistration() async {
    String nameVal = nameController.text.trim();
    String phoneVal = phoneController.text.trim();
    String referVal = referController.text.trim();

    if (nameVal.isNotEmpty && phoneVal.length == 10) {
      await helper.deleteCustomer(); // Clear any previous session to prevent bypass
      isLoading.value = true;
      update();

      try {
        debugPrint(
          "🚀 [RegistrationController] Starting registration for $phoneVal",
        );

        // Update observables for late use in OTP screen
        name.value = nameVal;
        phoneNumber.value = phoneVal;
        refer.value = referVal;

        authController.setRegisterFlow(true);
        authController.setIsFromRegistration(true);
        authController.setPhoneNumber(phoneVal);

        // Non-blocking FCM token retrieval
        try {
          FirebaseMessaging messaging = FirebaseMessaging.instance;
          NotificationSettings settings = await messaging
              .requestPermission(alert: true, badge: true, sound: true)
              .timeout(const Duration(seconds: 5));

          if (settings.authorizationStatus == AuthorizationStatus.authorized) {
            String? token = await messaging.getToken().timeout(
              const Duration(seconds: 5),
            );
            if (token != null) {
              authController.tokenGet.value = token;
              debugPrint(
                "📲 [RegistrationController] FCM Token obtained: $token",
              );
            }
          }
        } catch (fcmError) {
          debugPrint(
            " [RegistrationController] FCM Token error (continuing anyway): $fcmError",
          );
        }

        // Send OTP (authController handles the navigation to OTP screen in its codeSent callback)
        await authController.sendFirebaseOTP(Get.context!);
      } catch (e) {
        debugPrint(" [RegistrationController] Error in submitRegistration: $e");
        getFlutterToast("Registration error: $e", Colors.red);
      } finally {
        isLoading.value = false;
        update();
      }
    } else {
      if (nameVal.isEmpty) {
        getFlutterToast("Please enter your name.", Colors.red);
      } else if (phoneVal.length != 10) {
        getFlutterToast("Enter a valid 10-digit number.", Colors.red);
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    referController.dispose();
    super.onClose();
  }
}
