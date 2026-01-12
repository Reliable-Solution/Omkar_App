import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//packages
import 'package:get/get.dart';
import 'package:omkar_app/constant/api_endpoints.dart';
import 'package:omkar_app/constant/app_constant.dart';
import 'package:omkar_app/controller/authController.dart';
import 'package:omkar_app/controller/editController.dart';
import 'package:omkar_app/controller/homeController.dart';
import 'package:omkar_app/controller/registrationController.dart';
import 'package:omkar_app/utils/services/firebase_authenticate.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../models/customerModel.dart';
import '../utils/services/api_services.dart';
import '../utils/sharedPrefs.dart';
import '../view/dashboard/dashboardScreen.dart';
import '../view/otp/otp_screen.dart';
import 'networkController.dart';

class OTPController extends GetxController {
  NetworkController networkController = Get.put(NetworkController());
  EditProfileController editProfileController = Get.put(
    EditProfileController(),
  );

  // AuthController authController = AuthController();
  RegistrationController registrationController = RegistrationController();
  SharedHelper helper = SharedHelper();
  AuthController authController = Get.put(AuthController());
  // AuthController authController = Get.find<
  //     AuthController>(); // Find for shared state

  final HomeController homeController = Get.find<HomeController>();

  FocusNode? fFirstText;
  FocusNode? fSecondText;
  FocusNode? fThirdText;
  FocusNode? fFourText;
  FocusNode? fFiveText;
  FocusNode? fSixText;
  RxInt secondsRemaining = 60.obs;
  RxBool isResendEnabled = false.obs;
  Timer? _timer;
  var otpCode = "".obs;
  final otpControllerText = "".obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxString verificationIdCont = ''.obs;
  RxBool isLoading = false.obs;
  RxString v = "".obs;
  CustomerModel? m1 = CustomerModel();

  @override
  void onInit() async {
    fFirstText = FocusNode();
    fSecondText = FocusNode();
    fThirdText = FocusNode();
    fFourText = FocusNode();
    fFiveText = FocusNode();
    fSixText = FocusNode();
    startTimer();
    super.onInit();
  }

  void startTimer() {
    secondsRemaining.value = 60;
    isResendEnabled.value = false;

    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        isResendEnabled.value = true;
        _timer?.cancel();
      }
    });
    update();
  }

  void resendOTP(BuildContext context, String phoneNumber) {
    if (isResendEnabled.value) {
      startTimer();
      // authController.sendOTP(context, phoneNumber);
      authController.sendFirebaseOTP(context);
      print("Resending OTP via mobile...");
    }
  }

  @override
  void dispose() {
    fFirstText!.dispose();
    fSecondText!.dispose();
    fThirdText!.dispose();
    fFourText!.dispose();
    fFiveText!.dispose();
    fSixText!.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void nextFiled(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  // Firebase Verify (no API)
  // Future<void> verifyFirebaseOtp(BuildContext context, String otp,
  //     [String? phoneNumber]) async
  // {
  //   isLoading.value = true;
  //   update();
  //
  //   try {
  //     if (otp.length != 6) {
  //       throw "Enter a valid 6-digit OTP";
  //     }
  //
  //     // Delegate to AuthController
  //     await authController.verifyFirebaseOTP(otp, context);
  //
  //     // Success pe AuthController navigate karega, yahan extra work
  //     m1 = await helper.getCustomer(); // If needed
  //     editProfileController.GetProfile(customerId: m1?.customerId ?? '');
  //     // getFlutterToast("Login Successfully", Colors.green.shade900);
  //     homeController.getPrefs();
  //     homeController.getDashboardData(m1?.customerId);
  //     isLoading.value = false;
  //   } catch (e) {
  //     isLoading.value = false;
  //     print("CATCH verifyOtp: $e");
  //     getFlutterToast("Failed to verify OTP: Wrong or expired.", Colors.red);
  //     // Wrong pe ruk ja
  //   }
  //   Future<void> verifyPhoneOtp(BuildContext context, String otp,
  //       String phoneNumber) async {
  //     try {
  //       isLoading.value = true;
  //       if (otp.length != 6) {
  //         throw "Enter a valid 6-digit OTP";
  //       }
  //       print(otp);
  //       final Map<String, dynamic> body = {
  //         'otp': otp.trim(),
  //         'phone': phoneNumber.toString(),
  //       };
  //       var response = await ApiService.post(endpoint: VerifyOtp, body: body);
  //
  //       if (response.data['IsSuccess'] == true) {
  //         print("Responces Data ${response.data}");
  //
  //         // var data = response.data["Data"];
  //         var data = response.data['Data'];
  //         var userData = data['userData'];
  //
  //         if (userData is List && userData.isNotEmpty) {
  //           CustomerModel customerModel = CustomerModel.fromJson(userData[0]);
  //           helper.setCustomer(customerModel);
  //           editProfileController.GetProfile(
  //               customerId: customerModel.customerId!);
  //
  //           print("======= Customer Data Point ${customerModel.points}");
  //           getFlutterToast("Login Successfully", Colors.green.shade900);
  //           Future.delayed(Duration(seconds: 1), () {
  //             Get.offAll(() => DashboardScreen(pageIndex: 0));
  //           },);
  //           // Get.offAll(() => DashboardScreen(pageIndex: 0));
  //           homeController.getPrefs();
  //           homeController.getDashboardData(customerModel.customerId);
  //           update();
  //         }
  //       } else {
  //         print(" OTP Verification Failed: ${response.data['Message']}");
  //         print(" OTP Verification Failed: ${response.data}");
  //         getFlutterToast(response.data['Message'], Colors.red);
  //       }
  //     } catch (e) {
  //       isLoading.value = false;
  //       print(" CATCH verifyOtp: $e");
  //       getFlutterToast("Failed to verify OTP. Please try again.", Colors.red);
  //     }
  //   }
  //
  //
  //   Future<void> onFormSubmitted(BuildContext context, String otp,
  //       String phoneNumber) async {
  //     m1 = await helper.getCustomer();
  //     print("Trying OTP Verification...");
  //     await Future.delayed(Duration(seconds: 1));
  //
  //     if (otp.length != 6) {
  //       throw "Enter a valid 6-digit OTP";
  //     }
  //   }
  //
  //   @override
  //   void onClose() {
  //     _timer?.cancel();
  //     super.onClose();
  //   }
  // }
  Future<void> verifyLoginOtp(String otp, BuildContext context) async {
    try {
      isLoading.value = true;
      update();
      // await authController.firebaseAuth.signInWithCredential(credential);
      // Use AuthController's verificationId
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: authController.verificationId.value,
        smsCode: otp,
      );
      await authController.firebaseAuth.signInWithCredential(credential);
      // await FirebaseAuth.instance.signInWithCredential(credential);
      await authController.completeLogin(); // Login success work
    } catch (e) {
      getFlutterToast(_getErrorMsg(e.toString()), Colors.red);
    }
  }

  // Register: Verify Firebase OTP + Backend register
  Future<void> verifyRegisterOtp(
    BuildContext context, {
    String otp = "",
    String name = "",
    String phoneNumber = "",
    String referCode = "",
  }) async {
    try {
      isLoading.value = true;
      update();

      // Get the OTP screen widget to access the registration details
      // final OTPVerificationScreen? otpScreen = context.findAncestorWidgetOfExactType<OTPVerificationScreen>();
      // if (otpScreen?.name == null || otpScreen?.name?.isEmpty == true) {
      //   throw Exception("Name is required for registration");
      // }

      // Verify OTP with Firebase
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: authController.verificationId.value,
        smsCode: otp.trim(),
      );

      // Sign in with the credential
      await authController.firebaseAuth.signInWithCredential(credential);

      // After successful verification, register the user with backend
      print("======> Otp Controller Registering user with name: $name");
      final Map<String, dynamic> body = {
        'CustomerName': name ?? '',
        'CustomerEmailId': '',
        'CustomerPhoneNo': authController.phoneNumber.value ?? phoneNumber,
        'CustomerFCMToken': authController.tokenGet.value ?? referCode,
        'ReferCode': referCode ?? '',
        'FirmId': firmId,
      };

      print("Registration body: $body");
      var response = await ApiService.post(
        endpoint: newAddCustomer,
        body: body,
      );
      var res = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (res['IsSuccess'] == true &&
          res["Data"] is List &&
          res["Data"].isNotEmpty) {
        print("===========> Responces Data ${response.data}");
        // CustomerModel customer = CustomerModel.fromJson(res["Data"][0]);
        CustomerModel customer;
        if (res["Data"] is List && res["Data"].isNotEmpty) {
          customer = CustomerModel.fromJson(res["Data"][0]);
        } else {
          customer = CustomerModel.fromJson(res["Data"]);
        }
        authController.customerModel.value = customer;
        await helper.setCustomer(customer, "OTP Controller Register");
        authController.setRegisterFlow(false);
        editProfileController.GetProfile(
          customerId: authController.customerModel.value!.customerId!,
        );
        homeController.getPrefs();
        homeController.getDashboardData(
          authController.customerModel.value?.customerId,
        );
        getFlutterToast("Registration Successful", Colors.green);
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAll(() => DashboardScreen(pageIndex: 0));
        });
      } else {
        throw Exception(res['Message'] ?? "Register failed.");
      }
    } catch (e) {
      print("===========> OTP CONTROLLER $e");
      authController.setRegisterFlow(false);
      getFlutterToast(_getErrorMsg(e.toString()), Colors.red);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  String _getErrorMsg(String error) {
    // String lowerError = rawError.toLowerCase();
    String lowerError = error.toLowerCase();

    if (lowerError.contains('invalid-verification-code') ||
        lowerError.contains('signinwithcredential') ||
        lowerError.contains('pigeon') ||
        lowerError.contains('wrong') ||
        lowerError.contains('invalid code')) {
      return "Wrong OTP. Check and retry!";
    } else if (lowerError.contains('session-expired') ||
        lowerError.contains('timeout')) {
      return "OTP expired. Resend new one.";
    } else if (lowerError.contains('too-many-requests')) {
      return "Too many tries. Wait 1 min.";
    } else if (lowerError.contains('invalid-verification-id')) {
      return "Session invalid. Login again.";
    } else {
      return "Verification failed. Try again.";
    }
    // Tera smart error logic yahan paste kar
    // if (error.contains('invalid-verification-code')) return "Wrong OTP.";
    // return "Verification failed.";
  }
}
