import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omkar_app/constant/api_endpoints.dart';
import 'package:omkar_app/constant/app_constant.dart';
import 'package:omkar_app/models/customerModel.dart';
import 'package:omkar_app/view/dashboard/dashboardScreen.dart';
import 'package:omkar_app/controller/otpController.dart';
import '../utils/services/api_services.dart';
import '../utils/sharedPrefs.dart';
import 'package:omkar_app/utils/services/firebase_authenticate.dart';
import 'package:omkar_app/view/otp/otp_screen.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../view/otp/phone_auth.dart';
import 'authController.dart';
import 'homeController.dart';

class RegistrationController extends GetxController {
  final name = ''.obs;
  final email = ''.obs;
  final refer = ''.obs;

  var phoneNumber = ''.obs;
  final isNameValid = false.obs;
  final isReferValid = false.obs;
  final isEmailValid = false.obs;
  final isPhoneNumberValid = false.obs;
  SharedHelper helper = SharedHelper();
  FirebaseAuthenticate firebaseAuthenticate = FirebaseAuthenticate();
  final AuthController authController = Get.put(
    AuthController(),
  ); // Shared Firebase
  var otpCode = "".obs;
  final phoneController = "".obs;
  var isLoading = false.obs;

  final HomeController homeController = Get.find<HomeController>();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // getHintNumber();
  }

  /// Fetch mobile number hint with error handling
  Future<void> getHintNumber() async {
    try {
      String? phone = await SmsAutoFill().hint;
      if (phone != null) {
        phone = phone.replaceAll("+91", "").trim();
        phoneController.value = phone;
        print("============ ${phone}");
        phoneNumber.value = phone;

        update();
      }
    } catch (e) {
      print("Error : Failed to fetch mobile number: $e");
    }
  }

  /// Navigate to OTP Screen
  void sendOTP() {
    try {
      if (phoneNumber.value.length < 10) {
        throw "Invalid phone number";
      }
      // Get.to(OTPVerificationScreen(
      //   registerPhoneNumber: phoneNumber.value,
      // ));
    } catch (e) {
      getFlutterToast(e.toString(), Colors.red);
    }
  }

  void setName(String value) {
    name.value = value;
    isNameValid.value = value.isNotEmpty && value.length >= 3;
  }

  void setRefer(String value) {
    refer.value = value;
    isReferValid.value = value.isNotEmpty && value.length >= 3;
  }

  void setEmail(String value) {
    email.value = value;
    isEmailValid.value = RegExp(
      r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    ).hasMatch(value);
  }

  void setPhoneNumber(String value) {
    phoneNumber.value = value;
    isPhoneNumberValid.value = value.length == 10;
    isPhoneNumberValid.value = value.length == 10;
    update();
  }

  // void submitRegistration() {
  //   if (name.value.isNotEmpty && phoneNumber.value.isNotEmpty) {
  //     // getToken();
  //     getTokenAndSendOTP();
  //   } else {
  //     getFlutterToast("Please fill in all fields correctly.", Colors.red);
  //     update();
  //   }
  //   getTokenAndSendOTP();
  //   update();
  // }

  void submitRegistration() async {
    if (name.value.isNotEmpty && phoneNumber.isNotEmpty) {
      isLoading.value = true;
      update();

      try {
        authController.setRegisterFlow(true);
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          String? token = await messaging.getToken();
          if (token != null) {
            authController.tokenGet.value = token;
            authController.setPhoneNumber(phoneNumber.value);

            // Navigate to OTP screen with all registration details
            print(
              "======> Registering user with name: ${name.value}"
              "======> Registering user with email: ${email.value}"
              "======> Registering user with refer: ${refer.value}",
            );
            Get.to(
              () => OTPVerificationScreen(
                phoneNumber: phoneNumber.value,
                registerPhoneNumber: phoneNumber.value,
                name: name.value,
                // email: email.value,
                referCode: refer.value,
              ),
            );

            // Start OTP timer
            OTPController otpController = Get.put(OTPController());
            otpController.startTimer();

            // Send OTP
            await authController.sendFirebaseOTP(Get.context!);
          }
        }
      } catch (e) {
        getFlutterToast("Error: $e", Colors.red);
      } finally {
        isLoading.value = false;
        update();
      }
    } else {
      getFlutterToast("Fill details correctly.", Colors.red);
    }
  }

  void getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    isLoading.value = true;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      String? token = await messaging.getToken();
      // registerUser(context,token!);
      print('FCM Token: $token');
    } else {
      print('User declined or has not accepted permission');
    }
    isLoading.value = false;
  }

  registerUser(BuildContext context, String token) async {
    try {
      final Map<String, dynamic> body = {
        'CustomerName': name.value.toString(),
        'CustomerEmailId': "",
        'CustomerPhoneNo': phoneNumber.value.toString(),
        'CustomerFCMToken': token,
        'ReferCode': refer.value.toString(),
        'FirmId': firmId,
      };

      print("Request Body: $body");

      var response = await ApiService.post(
        endpoint: newAddCustomer,
        body: body,
      );
      print("Response Data: ${response.data.runtimeType}");
      // print("======== Response Data: ${response.data['IsSuccess']}")z;
      // print("Response Data message: ${response.data['Message']}");

      var res;
      if (response.data is String) {
        res = jsonDecode(response.data);
      } else {
        res = response.data;
      }
      print("=========== responces Data ${res}");
      if (res['IsSuccess'] == true) {
        var data = res["Data"];

        if (data is List && data.isNotEmpty) {
          sendOTPPhone(context, phoneNumber.value);
          // Get.to(() => OTPVerificationScreen(registerPhoneNumber: phoneNumber.value));
        } else if (data == 0) {
          getFlutterToast(
            "You already have an account. Please sign in.",
            Colors.red,
          );
          Get.offAll(() => LoginScreen());
        } else {
          getFlutterToast(
            "Registration successful, but no data received.",
            Colors.red,
          );
        }
        // CustomerModel customerModel =
        //     CustomerModel.fromJson(response.data["Data"][0]);
        //
        // print("Customer Name: ${customerModel.customerName}");
        //
        // helper.setCustomer(customerModel);
        // Get.to(() =>
        //     OTPVerificationScreen(registerPhoneNumber: phoneNumber.value));

        // Get.offAll(() => DashboardScreen(pageIndex: 0));
        update();
      }
      // else if (response.data['Message'] == "Customer Already Register") {
      //   Get.offAll(() => LoginScreen());
      // }
      else {
        getFlutterToast(response.data['Message'], Colors.red);
      }
    } catch (e) {
      print("Error in register: $e");
      getFlutterToast("Failed to register. Please try again.'", Colors.red);
      throw Exception("Failed to register");
    }
  }

  Future<void> sendOTPPhone(BuildContext context, String phoneNumber) async {
    try {
      isLoading.value = true; // Loader start

      if (phoneNumber.isEmpty || phoneNumber.length < 10) {
        snackBarMessengers(
          context,
          message: "Please enter a valid phone number.",
        );
        return;
      }
      // Request body
      final Map<String, dynamic> body = {
        "dial_code": "91",
        "phone": phoneNumber.toString(),
      };
      print('Request Body Phone Number : $body');

      // Dio POST call
      var response = await ApiService.post(endpoint: SendOtp, body: body);
      if (response.data['IsSuccess'] == true) {
        getFlutterToast("OTP sent to your mobile.", Colors.green);
        Get.to(() => OTPVerificationScreen(phoneNumber: phoneNumber));
        isLoading.value = false;
        update();
      } else {
        getFlutterToast(response.data['Message'], Colors.red);
      }
    } catch (e) {
      isLoading.value = false;
      print("Error in sendOtp: $e");
      getFlutterToast("Something went wrong. Please try again.", Colors.red);
    }
  }

  // Get token and send Firebase OTP
  void getTokenAndSendOTP() async {
    isLoading.value = true;
    update();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      if (token != null) {
        authController.tokenGet.value = token; // Shared token
        authController.setPhoneNumber(phoneNumber.value); // Shared phone
        await authController.sendFirebaseOTP(Get.context!); // Firebase OTP send
      }
    }
    isLoading.value = false;
    update();
  }

  snackBarMessengers(context, {message, color, isDuration = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      isDuration
          ? SnackBar(
              duration: const Duration(milliseconds: 500),
              content: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color ?? Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message.toString(),
                  // style: appCss.dmDenseMedium16
                  //     .textColor(appColor(context).whiteBg)
                ),
              ),
              backgroundColor: Colors.transparent,
              behavior: SnackBarBehavior.floating,
              elevation: 0,
              padding: EdgeInsets.zero,
            )
          : SnackBar(
              content: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color ?? Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message.toString(),
                  // style: appCss.dmDenseMedium16
                  //     .textColor(Colors.white)
                ),
              ),
              backgroundColor: Colors.transparent,
              behavior: SnackBarBehavior.floating,
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
    );
  }
}
