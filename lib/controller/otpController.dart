import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

//packages
import 'package:get/get.dart';
import 'package:omkar_app/constant/api_endpoints.dart';
import 'package:omkar_app/constant/app_constant.dart';
import 'package:omkar_app/controller/authController.dart';
import 'package:omkar_app/controller/editController.dart';
import 'package:omkar_app/controller/homeController.dart';
import 'package:omkar_app/controller/registrationController.dart';
import 'package:omkar_app/controller/addUserController.dart';
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
  late AuthController authController;

  @override
  void onInit() {
    fFirstText = FocusNode();
    fSecondText = FocusNode();
    fThirdText = FocusNode();
    fFourText = FocusNode();
    fFiveText = FocusNode();
    fSixText = FocusNode();
    startTimer();
    super.onInit();
    // Find existing AuthController instead of creating new one
    authController = Get.find<AuthController>();
  }

  // AuthController authController = Get.find<
  //     AuthController>(); // Find for shared state

  final HomeController homeController = Get.find<HomeController>();

  FocusNode? fFirstText;
  FocusNode? fSecondText;
  FocusNode? fThirdText;
  FocusNode? fFourText;
  FocusNode? fFiveText;
  FocusNode? fSixText;
  RxInt secondsRemaining = 120.obs;
  RxBool isResendEnabled = false.obs;
  Timer? _timer;
  var otpCode = "".obs;
  final otpControllerText = "".obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxString verificationIdCont = ''.obs;
  RxBool isLoading = false.obs;
  RxString v = "".obs;
  CustomerModel? m1 = CustomerModel();
  
  // Prevent multiple concurrent OTP verification requests
  bool _isVerificationInProgress = false;

  // @override
  // void onInit() async {
  //   fFirstText = FocusNode();
  //   fSecondText = FocusNode();
  //   fThirdText = FocusNode();
  //   fFourText = FocusNode();
  //   fFiveText = FocusNode();
  //   fSixText = FocusNode();
  //   startTimer();
  //   super.onInit();
  // }

  void startTimer() {
    secondsRemaining.value = 120;
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
      authController.sendFirebaseOTP(context, navigateToOtp: false);
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
    // Prevent multiple concurrent verification requests
    if (_isVerificationInProgress) {
      debugPrint("✗ OTP verification already in progress. Ignoring duplicate request.");
      return;
    }

    _isVerificationInProgress = true;
    try {
      isLoading.value = true;
      update();
      final verificationId = authController.verificationId.value;
      debugPrint(
        "==> verifyLoginOtp: verificationId = ${authController.verificationId.value}",
      );
      debugPrint("==> verifyLoginOtp: OTP = $otp");
      debugPrint(
        "==> verifyLoginOtp: customerModel = ${authController.customerModel.value?.customerName}, customerId = ${authController.customerModel.value?.customerId}",
      );

      // Validate verificationId before creating credential
      if (verificationId.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-verification-id',
          message: 'Verification ID is empty. Please request OTP again.',
        );
      }

      if (otp.isEmpty || otp.length < 6) {
        throw FirebaseAuthException(
          code: 'invalid-verification-code',
          message: 'Please enter a valid 6-digit OTP.',
        );
      }

      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp.trim(),
        );
        
        debugPrint("✓ PhoneAuthCredential created successfully");
        
        await authController.firebaseAuth.signInWithCredential(credential);
        debugPrint("✓ Firebase credential signed in successfully");
        
        await authController.completeLogin(); // Login success work
      } on FirebaseAuthException catch (firebaseEx) {
        throw firebaseEx; // Re-throw for handling below
      } on PlatformException catch (platEx) {
        // Handle platform-specific errors (especially iOS)
        debugPrint("✗ PlatformException in credential sign-in: ${platEx.code} - ${platEx.message}");
        
        if (platEx.code.contains('nil') || platEx.code.contains('unwrap')) {
          throw FirebaseAuthException(
            code: 'authentication-failed',
            message: 'Authentication service error on iOS. Please try again.',
          );
        }
        
        throw platEx;
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg;

      switch (e.code) {
        case 'invalid-verification-code':
          errorMsg = "Wrong OTP entered. Please try again.";
          break;
        case 'invalid-verification-id':
        case 'session-expired':
          errorMsg = "Session expired. Please request a new OTP.";
          break;
        case 'too-many-requests':
          errorMsg = "Too many attempts. Try again later.";
          break;
        case 'authentication-failed':
          errorMsg = e.message ?? "Authentication failed. Please try again.";
          break;
        default:
          errorMsg = e.message ?? "Authentication failed. Please try again.";
      }

      debugPrint("==> FirebaseAuthException: ${e.code} - ${e.message}");
      getFlutterToast(errorMsg, Colors.red);
    } on PlatformException catch (e) {
      debugPrint("==> PlatformException: ${e.code} - ${e.message}");
      getFlutterToast("Platform error: ${e.message}", Colors.red);
    } catch (e) {
      debugPrint("==> verifyLoginOtp ERROR: $e");
      getFlutterToast(_getErrorMsg(e.toString()), Colors.red);
    } finally {
      isLoading.value = false;
      _isVerificationInProgress = false;
      update();
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
    // Prevent multiple concurrent verification requests
    if (_isVerificationInProgress) {
      debugPrint("✗ OTP verification already in progress. Ignoring duplicate request.");
      return;
    }

    _isVerificationInProgress = true;
    try {
      isLoading.value = true;
      update();

      final verificationId = authController.verificationId.value;

      // Validate verificationId before creating credential
      if (verificationId.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-verification-id',
          message: 'Verification ID is empty. Please request OTP again.',
        );
      }

      if (otp.isEmpty || otp.length < 6) {
        throw FirebaseAuthException(
          code: 'invalid-verification-code',
          message: 'Please enter a valid 6-digit OTP.',
        );
      }

      try {
        // Verify OTP with Firebase
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp.trim(),
        );

        debugPrint("✓ PhoneAuthCredential created for registration");

        // Sign in with the credential
        await authController.firebaseAuth.signInWithCredential(credential);
        
        debugPrint("✓ Firebase credential signed in for registration");
      } on FirebaseAuthException catch (firebaseEx) {
        throw firebaseEx;
      } on PlatformException catch (platEx) {
        // Handle platform-specific errors (especially iOS)
        debugPrint("✗ PlatformException in registration: ${platEx.code} - ${platEx.message}");
        
        if (platEx.code.contains('nil') || platEx.code.contains('unwrap')) {
          throw FirebaseAuthException(
            code: 'authentication-failed',
            message: 'Authentication service error on iOS. Please try again.',
          );
        }
        
        throw platEx;
      }

      // After successful verification, register the user with backend
      print("=======> Otp Controller Registering user with name: $name");
      print("=======> Verification ID: $verificationId");

      final Map<String, dynamic> body = {
        'CustomerName': name,
        'CustomerEmailId': '',
        'CustomerPhoneNo': authController.phoneNumber.value.isEmpty
            ? phoneNumber
            : authController.phoneNumber.value,
        'CustomerFCMToken': authController.tokenGet.value,
        'ReferCode': referCode,
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

      if (res['IsSuccess'] == true || res['IsSuccess'] == 'true') {
        if ((res["Data"] is List && res["Data"].isNotEmpty) ||
            (res["Data"] is Map && res["Data"].isNotEmpty)) {
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
          await editProfileController.GetProfile(
            customerId: authController.customerModel.value!.customerId!,
          );
          await homeController.getPrefs();
          await homeController.getDashboardData(
            authController.customerModel.value?.customerId,
          );
          // Clear AddUser fields only after successful OTP verification
          if (Get.isRegistered<AddUserController>()) {
            Get.find<AddUserController>().clearFields();
          }

          getFlutterToast("Registration Successful", Colors.green);
          // await Future.delayed(const Duration(seconds: 1));
          Get.offAll(() => DashboardScreen(pageIndex: 0));
        } else {
          isLoading.value = false;
          update();
          getFlutterToast("Registration failed: No data found.", Colors.red);
        }
      } else {
        throw Exception(res['Message'] ?? "Register failed.");
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("==> FirebaseAuthException in registration: ${e.code} - ${e.message}");
      isLoading.value = false;
      update();
      authController.setRegisterFlow(false);
      getFlutterToast(_getErrorMsg(e.toString()), Colors.red);
    } on PlatformException catch (e) {
      debugPrint("==> PlatformException in registration: ${e.code} - ${e.message}");
      isLoading.value = false;
      update();
      authController.setRegisterFlow(false);
      getFlutterToast("Platform error during registration: ${e.message}", Colors.red);
    } catch (e) {
      print("===========> OTP CONTROLLER $e");
      isLoading.value = false;
      update();
      authController.setRegisterFlow(false);
      getFlutterToast(_getErrorMsg(e.toString()), Colors.red);
    } finally {
      _isVerificationInProgress = false;
    }
  }

  String _getErrorMsg(String error) {
    String lowerError = error.toLowerCase();

    if (lowerError.contains('invalid-verification-code') ||
        lowerError.contains('invalid-otp') ||
        lowerError.contains('wrong-otp') ||
        lowerError.contains('invalid code')) {
      return "Wrong OTP. Check and retry!";
    } else if (lowerError.contains('session-expired') ||
        lowerError.contains('timeout')) {
      return "OTP expired. Resend new one.";
    } else if (lowerError.contains('too-many-requests')) {
      return "Too many tries. Wait 1 min.";
    } else if (lowerError.contains('invalid-verification-id')) {
      return "Session invalid. Login again.";
    } else if (lowerError.contains('admin-restricted-operation')) {
      return "This operation is restricted. Please check your admin settings.";
    } else if (lowerError.contains('internal-error')) {
      return "An internal error occurred. Please try again later.";
    } else if (lowerError.contains('network-request-failed')) {
      return "Network error. Please check your internet connection.";
    } else if (lowerError.contains('user-disabled')) {
      return "This user has been disabled. Contact support.";
    } else if (lowerError.contains('quota-exceeded')) {
      return "SMS quota exceeded. Please try again later.";
    } else {
      return "Verification failed: $error"; // Return full error for debugging if unknown
    }
    // Tera smart error logic yahan paste kar
    // if (error.contains('invalid-verification-code')) return "Wrong OTP.";
    // return "Verification failed.";
  }
}
