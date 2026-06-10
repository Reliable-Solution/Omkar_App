import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:omkar_app/constant/api_endpoints.dart';
import 'package:omkar_app/constant/colorConst.dart';
import 'package:omkar_app/controller/otpController.dart';
import '../constant/app_constant.dart';
import '../models/customerModel.dart';
import '../utils/services/api_services.dart';
import '../utils/string_res.dart';
import '../utils/sharedPrefs.dart';
import '../view/dashboard/dashboardScreen.dart';
import '../view/otp/otp_screen.dart';
import '../view/otp/addUserScreen.dart';
import '../view/otp/phone_auth.dart';
import '../view/otp/approval_pending_screen.dart';
import 'editController.dart';
import 'addUserController.dart';
import 'homeController.dart';

class AuthController extends GetxController {
  final phoneNumber = ''.obs;
  TextEditingController numberController = TextEditingController();
  late final HomeController homeController;
  EditProfileController editProfileController = Get.put(
    EditProfileController(),
  );

  final verificationId = ''.obs;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance; // Add this
  Rx<CustomerModel?> customerModel = CustomerModel().obs;

  // RegistrationController controller = Get.find();

  // final verificationId = ''.obs;
  final otp = ''.obs;
  final isOtpValid = false.obs;
  SharedHelper helper = SharedHelper();
  RxString tokenGet = "".obs;
  final isLoading = false.obs;
  String dialCode = "+91";
  final isRegisterFlow = false.obs;
  final isFromRegistration = false.obs;

  // Prevent multiple concurrent OTP requests
  bool _isOtpRequestInProgress = false;

  @override
  void onInit() {
    super.onInit();
    // Initialize HomeController lazily
    homeController = Get.find<HomeController>();
  }

  void setRegisterFlow(bool value) {
    isRegisterFlow.value = value;
  }

  void setIsFromRegistration(bool value) {
    isFromRegistration.value = value;
  }

  void setPhoneNumber(String value) {
    phoneNumber.value = value;
  }

  void setOtp(String value) {
    otp.value = value;
    isOtpValid.value = value.length == 6; // Validate OTP length
  }

  Future<void> getData() async {
    CustomerModel? customer = await helper.getCustomer();
    if (customer != null) {
      customerModel.value = customer;
      debugPrint(" Name: ${customer.customerName}");
      debugPrint("=========>  Name and Points: ${customer.points}");
      debugPrint("Controller hash in HomeController: $hashCode");
      debugPrint("Updated Name: ${customer.customerName}");
      update(); // agar tu GetBuilder bhi use kar raha hai
    }
  }

  Future<void> sendOTP(BuildContext context, String phoneNumber) async {
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
        // "dial_code": "91",
        "phone": phoneNumber.toString(),
      };
      debugPrint('Request Body Phone Number : $body');

      // Dio POST call
      var response = await ApiService.post(endpoint: SendOtp, body: body);
      if (response.data['IsSuccess'] == true) {
        getFlutterToast("OTP sent to your mobile.", Colors.green.shade900);
        Get.to(() => OTPVerificationScreen(phoneNumber: phoneNumber));

        OTPController otpController = Get.isRegistered<OTPController>()
            ? Get.find<OTPController>()
            : Get.put(OTPController(), permanent: true);

        otpController.startTimer();
        isLoading.value = false;
        update();
      } else {
        getFlutterToast(response.data['Message'], Colors.red);
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint("Error in sendOtp: $e");
      getFlutterToast("Something went wrong. Please try again.", Colors.red);
    }
  }

  // Future<void> sendOTPPhone(BuildContext context) async {
  //   try {
  //     try {
  //       isLoading.value = true;
  //
  //       final Map<String, dynamic> body = {
  //         'CustomerPhoneNo': phoneNumber.value.toString(),
  //         "CustomerFCMToken": tokenGet,
  //       };
  //       debugPrint('Request Body: $body');
  //
  //       var response = await ApiService.post(endpoint: login, body: body);
  //       isLoading.value = false;
  //
  //       if (response.data['IsSuccess'] == true) {
  //         var data = response.data["Data"];
  //
  //         if (data is List && data.isNotEmpty) {
  //           var userData = data[0];  // Assume first item user details, agar 'userData' key hai to data['userData'][0]
  //            customerModel.value = CustomerModel.fromJson(userData);
  //           await helper.setCustomer(customerModel!.value!);  // Save in SharedPrefs
  //           debugPrint("User data saved: ${customerModel.value!.customerId}");  // Check
  //           await sendFirebaseOTP(context);
  //           // sendOTP(context, phoneNumber.value.toString());
  //         } else if (data is List && data.isEmpty) {
  //           getFlutterToast(
  //               "No account found. Please register.", Colors.black54);
  //           debugPrint("=======> Phone Number ${phoneNumber.value}");
  //           // controller.phoneNumber.value = phoneNumber.value.toString();
  //           // debugPrint("=======> Phone Number ${controller.phoneNumber.value}");
  //           // txtNumber
  //           Get.offAll(() => RegistrationScreen(
  //                 phone: phoneNumber.value.toString(),
  //               ));
  //         } else {
  //           getFlutterToast("Unexpected response received.", Colors.red);
  //         }
  //       } else {
  //         getFlutterToast(response.data['Message'], Colors.red);
  //       }
  //     } catch (e) {
  //       isLoading.value = false;
  //
  //       debugPrint("Error in register: $e");
  //       getFlutterToast("Failed to register. Please try again.", Colors.red);
  //       throw Exception("Failed to register");
  //     }
  //   } catch (e) {
  //     print(e);
  //     getFlutterToast("Failed to register", Colors.red);
  //   }
  // }
  //
  //
  // // New: Firebase OTP Send
  // Future<void> sendFirebaseOTP(BuildContext context) async {
  //   isLoading.value = true;
  //   update();
  //
  //   String fullPhone = '$dialCode${phoneNumber.value}';  // +91xxxxxxxxxx
  //
  //   await firebaseAuth.verifyPhoneNumber(
  //     phoneNumber: fullPhone,
  //     verificationCompleted: (PhoneAuthCredential credential) async {
  //       // Auto-retrieval (Android mostly)
  //       await firebaseAuth.signInWithCredential(credential);
  //       isLoading.value = false;
  //       Get.to(() => OTPVerificationScreen());  // Success navigation, replace with your dashboard
  //       getFlutterToast("Login successful!", Colors.green);
  //     },
  //     verificationFailed: (FirebaseAuthException e) {
  //       isLoading.value = false;
  //       debugPrint("Verification Failed: ${e.message}");
  //       getFlutterToast(e.message ?? "OTP send failed.", Colors.red);
  //     },
  //     codeSent: (String verId, int? resendToken) {
  //       verificationId.value = verId;
  //       isLoading.value = false;
  //       Get.to(() => OTPVerificationScreen(phoneNumber: phoneNumber.value));
  //       OTPController otpController = Get.put(OTPController());
  //       otpController.startTimer();
  //       getFlutterToast("OTP sent via Mobile.", Colors.green);
  //     },
  //     codeAutoRetrievalTimeout: (String verId) {
  //       verificationId.value = verId;
  //     },
  //     timeout: const Duration(seconds: 60),
  //   );
  // }
  // Login: API check if user exists, then Firebase OTP
  Future<void> sendOTPPhone(BuildContext context) async {
    try {
      isLoading.value = true;
      // Check if account was previously deleted
      bool? isDeleted = await helper.getStoredBool(
        key: SharedHelper.deleteAccountKey,
      );
      if (isDeleted == true) {
        isLoading.value = false;
        getFlutterToast(StringRes.accountDeleted, Colors.red);
        return;
      }

      final Map<String, dynamic> body = {
        'CustomerPhoneNo': phoneNumber.value,
        "CustomerFCMToken": tokenGet.value,
      };
      var response = await ApiService.post(endpoint: login, body: body);
      isLoading.value = false;

      var res = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (res['IsSuccess'] == true || res['IsSucess'] == true) {
        var data = res["Data"];
        if ((data is List && data.isNotEmpty) ||
            (data is Map && data.isNotEmpty)) {
          setRegisterFlow(false);
          var userData = (data is List) ? data[0] : data;
          customerModel.value = CustomerModel.fromJson(userData);
          debugPrint(
            " Customer loaded in memory: ${customerModel.value?.customerName} (${customerModel.value?.customerId})",
          );
          await sendFirebaseOTP(context); // Trigger Firebase OTP
        } else {
          getFlutterToast(
            "Account not found or pending approval. (Err: Empty Data)",
            Colors.black54,
          );
          Get.offAll(() => AddUserScreen(phone: phoneNumber.value));
        }
      } else {
        getFlutterToast("${res['Message']} (Err: IsSuccess False)", Colors.red);
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint("Full Error: $e");
      getFlutterToast(
        "Failed to login (Err: Exception). Try again.",
        Colors.red,
      );
    }
  }

  Future<void> sendFirebaseOTP(
    BuildContext context, {
    bool navigateToOtp = true,
  }) async {
    // Prevent multiple concurrent OTP requests
    if (_isOtpRequestInProgress) {
      debugPrint(
        "✗ OTP request already in progress. Ignoring duplicate request.",
      );
      return;
    }

    _isOtpRequestInProgress = true;
    isLoading.value = true;
    update();

    try {
      // Clear previous verification ID
      verificationId.value = '';

      String fullPhone = '$dialCode${phoneNumber.value}';

      // On iOS, wait for APNS setup before attempting phone verification
      if (Platform.isIOS) {
        debugPrint(
          "⏳ iOS: Waiting for APNS setup before phone verification...",
        );
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      // On iOS simulator, use longer timeout to handle reCAPTCHA fallback
      final duration = Platform.isIOS
          ? Duration(seconds: 180) // iOS: 3 minutes (reCAPTCHA takes longer)
          : Duration(seconds: 60);

      debugPrint("🔄 Starting Firebase Phone Verification for: $fullPhone");

      try {
        await firebaseAuth.verifyPhoneNumber(
          phoneNumber: fullPhone,
          verificationCompleted: (credential) async {
            //  Force manual verification for testing manual flow
            //  Auto-verification disabled
            debugPrint(
              "✓ Manual testing: Auto-verification detected, but waiting for user input.",
            );
            isLoading.value = false;
            update();
          },
          verificationFailed: (e) {
            isLoading.value = false;
            verificationId.value = '';
            debugPrint("✗ Verification Failed: ${e.code} - ${e.message}");

            String errorMsg = e.message ?? "OTP send failed.";

            // Handle specific iOS APNS errors
            if (Platform.isIOS && e.code == 'missing-client-identifier') {
              errorMsg =
                  "Push notification setup incomplete. Using OTP verification.";
            }

            getFlutterToast(errorMsg, Colors.red);
          },
          codeSent: (verId, resendToken) {
            verificationId.value = verId;
            debugPrint("✓ Verification ID captured: $verId");

            // Show success message immediately
            getFlutterToast(
              "OTP sent to ${phoneNumber.value}",
              COLOR.appBaseColor,
            );

            // Navigate after a small delay to ensure message is visible
            Future.delayed(const Duration(milliseconds: 800), () {
              if (navigateToOtp) {
                Get.to(
                  () => OTPVerificationScreen(
                    phoneNumber: phoneNumber.value,
                    registerPhoneNumber: isRegisterFlow.value
                        ? phoneNumber.value
                        : "",
                  ),
                );
              }

              OTPController otpController = Get.isRegistered<OTPController>()
                  ? Get.find<OTPController>()
                  : Get.put(OTPController(), permanent: true);

              otpController.startTimer();

              // Reset loader AFTER navigation is complete
              isLoading.value = false;
              update();
            });
          },
          codeAutoRetrievalTimeout: (verId) {
            verificationId.value = verId;
            debugPrint(
              "✓ Auto retrieval timeout - Verification ID set: $verId",
            );
          },
          timeout: duration,
        );
      } on PlatformException catch (platEx) {
        // Catch iOS-specific platform exceptions
        isLoading.value = false;
        debugPrint(
          "✗ PlatformException in verifyPhoneNumber: ${platEx.code} - ${platEx.message}",
        );

        String errorMsg =
            "Platform error during phone verification: ${platEx.message}";
        if (platEx.code.contains('nil') || platEx.code.contains('unwrap')) {
          errorMsg =
              "iOS configuration error. Please try again or contact support.";
        }

        getFlutterToast(errorMsg, Colors.red);
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      isLoading.value = false;
      debugPrint(
        "✗ sendFirebaseOTP FirebaseAuthException: ${e.code} - ${e.message}",
      );

      String errorMsg = "Failed to send OTP.";

      switch (e.code) {
        case 'missing-client-identifier':
          errorMsg = "Device not properly configured for authentication.";
          break;
        case 'app-not-authorized':
          errorMsg = "App is not authorized for this operation.";
          break;
        case 'invalid-phone-number':
          errorMsg = "Invalid phone number format.";
          break;
        case 'too-many-requests':
          errorMsg = "Too many attempts. Please use a Test Number or try again after 30 minutes.";
          break;
        default:
          errorMsg = e.message ?? "Failed to send OTP. Please try again.";
      }

      getFlutterToast(errorMsg, Colors.red);
    } catch (e) {
      // Handle any other unexpected errors
      isLoading.value = false;
      debugPrint("✗ sendFirebaseOTP Unexpected Error: $e");
      getFlutterToast("Unexpected error: $e", Colors.red);
    } finally {
      _isOtpRequestInProgress = false;
      update();
    }
  }

  // Login: Post Firebase success work (customer fetch etc.)
  Future<void> completeLogin() async {
    if (customerModel.value == null) {
      throw Exception("Customer data missing.");
    }

    //  If customerId is null (AddUser flow), call Login API to get proper data
    if (customerModel.value!.customerId == null ||
        customerModel.value!.customerId!.isEmpty) {
      debugPrint(" CustomerId is null — Fetching proper data via Login API...");

      try {
        final Map<String, dynamic> loginBody = {
          'CustomerPhoneNo': phoneNumber.value,
          'CustomerFCMToken': tokenGet.value,
        };
        var loginResponse = await ApiService.post(
          endpoint: login,
          body: loginBody,
        );
        var loginRes = loginResponse.data is String
            ? jsonDecode(loginResponse.data)
            : loginResponse.data;

        debugPrint("🔄 Login API Response: $loginRes");

        if (loginRes['IsSuccess'] == true || loginRes['IsSucess'] == true) {
          var data = loginRes["Data"];
          if ((data is List && data.isNotEmpty) ||
              (data is Map && data.isNotEmpty)) {
            //  Got proper customer data with CustomerId!
            var userData = (data is List) ? data[0] : data;
            customerModel.value = CustomerModel.fromJson(userData);
            debugPrint(
              " Login API: Got CustomerId = ${customerModel.value?.customerId}",
            );
          } else {
            //  User is still pending — Show Approval Pending screen
            debugPrint(
              " Login API returned empty data — User is pending approval",
            );

            // Clear AddUser fields
            if (Get.isRegistered<AddUserController>()) {
              Get.find<AddUserController>().clearFields();
            }

            getFlutterToast(
              "✓ Registration submitted! Your account is pending approval.",
              Colors.orange,
            );

            // Save carpenter pending flag so it survives app restart
            try {
              await helper.setCarpenterPendingStatus(true, phoneNumber.value);
            } catch (e) {
              debugPrint("Failed to save pending status: $e");
            }

            // Show Approval Pending screen
            Get.offAll(
              () => ApprovalPendingScreen(customer: customerModel.value),
            );
            return; // Don't continue further
          }
        }
      } catch (e) {
        debugPrint(" Login API call failed: $e");
      }
    }

    //  OTP verified successfully — NOW save customer data to SharedPreferences
    await helper.setCustomer(
      customerModel.value!,
      "CompleteLogin - After OTP Verified",
    );
    debugPrint(
      " Customer data saved to SharedPrefs — CustomerId: ${customerModel.value?.customerId}",
    );

    try {
      //  Only call GetProfile if customerId exists
      if (customerModel.value!.customerId != null &&
          customerModel.value!.customerId!.isNotEmpty) {
        await editProfileController.GetProfile(
          customerId: customerModel.value!.customerId!,
        );
      }

      await homeController.getPrefs();
      await homeController.getDashboardData(customerModel.value?.customerId);
    } catch (e) {
      debugPrint("⚠️ Error during profile/dashboard fetch: $e");
      // Continue anyway - data already saved
    }

    //  Clear AddUser fields after successful OTP + login
    if (Get.isRegistered<AddUserController>()) {
      Get.find<AddUserController>().clearFields();
    }

    if (isFromRegistration.value) {
      getFlutterToast("Registration Successfully", COLOR.appBaseColor);
      isFromRegistration.value = false; // Reset the flag
    } else {
      getFlutterToast("Login Successful", COLOR.appBaseColor);
    }

    // Future.delayed(const Duration(seconds: 1), () {
    Get.offAll(() => DashboardScreen(pageIndex: 0));
    // });
  }

  // New: Verify OTP (Call this from OTP Screen on submit)
  // Future<void> verifyFirebaseOTP(String otpCode, BuildContext context) async {
  //   isLoading.value = true;
  //   update();
  //
  //   try {
  //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: verificationId.value,
  //       smsCode: otpCode,
  //     );
  //
  //     await firebaseAuth.signInWithCredential(credential);
  //     isLoading.value = false;
  //
  //     // Get.to(() => DashboardScreen(pageIndex: 0));  // Success: Navigate to dashboard
  //     getFlutterToast("OTP verified successfully!", Colors.green);
  //     // CustomerModel customerModel = CustomerModel.fromJson(userData[0]);
  //     // helper.setCustomer(customerModel);
  //     // editProfileController.GetProfile(
  //     //     customerId: customerModel.customerId!);
  //     //
  //     // print("======= Customer Data Point ${customerModel.points}");
  //     // getFlutterToast("Login Successfully", Colors.green.shade900);
  //     Future.delayed(Duration(seconds: 1), () {
  //       Get.offAll(() => DashboardScreen(pageIndex: 0));
  //     },);
  //     // Get.offAll(() => DashboardScreen(pageIndex: 0));
  //    // customerModel.value= (await helper.getCustomer())!;
  //     editProfileController.GetProfile(
  //         customerId: customerModel!.value!.customerId!);
  //     homeController.getPrefs();
  //     homeController.getDashboardData(customerModel.value?.customerId);
  //     update();
  //     // Yahan additional API call kar sakta hai if needed (like save Firebase UID)
  //   } on FirebaseAuthException catch (e) {
  //     isLoading.value = false;
  //     debugPrint("OTP Verify Error: ${e.message}");
  //     if (e.code == 'invalid-verification-code') {
  //       getFlutterToast("Wrong OTP entered. Try again.", Colors.red);
  //     } else {
  //       getFlutterToast(e.message ?? "Verification failed.", Colors.red);
  //     }
  //     // Wrong OTP pe yahan return, navigate mat
  //   } catch (e) {
  //     isLoading.value = false;
  //     getFlutterToast("Something went wrong.", Colors.red);
  //   }
  // }

  // Future<void> verifyFirebaseOTP(String otpCode, BuildContext context,{bool isRegister = false}) async {
  //   isLoading.value = true;
  //   update();
  //
  //   try {
  //     if (otpCode.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otpCode)) {
  //       throw FirebaseAuthException(code: 'invalid-otp', message: 'OTP must be 6 digits');
  //     }
  //
  //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: verificationId.value,
  //       smsCode: otpCode,
  //     );
  //
  //     // Ye throw karega wrong OTP pe
  //     await firebaseAuth.signInWithCredential(credential);
  //
  //     // SUCCESS ONLY
  //     // isLoading.value = false;
  //     // _showToast("OTP verified successfully!", Colors.green);
  //     // getFlutterToast("Login Successfully", Colors.green.shade900);
  //
  //
  //
  //     if (isRegister) {
  //       // Register case: Backend API call kar
  //       await _registerBackend(context);  // New method call
  //     } else {
  //       editProfileController.GetProfile(
  //           customerId: customerModel.value!.customerId!);
  //       homeController.getPrefs();
  //       homeController.getDashboardData(customerModel.value?.customerId);
  //     }
  //
  //     isLoading.value = false;
  //     getFlutterToast(isRegister ? "Registration Successful" : "Login Successful", Colors.green.shade900);
  //     Future.delayed(const Duration(seconds: 1), () {
  //       Get.offAll(() => DashboardScreen(pageIndex: 0));
  //     });
  //     update();
  //   } on FirebaseAuthException catch (e) {
  //     isLoading.value = false;
  //     debugPrint("Firebase OTP Error: ${e.code} - ${e.message}");
  //
  //     String errorMsg = "Verification failed. Please try again.";
  //     Color toastColor = Colors.red;
  //
  //     switch (e.code) {
  //       case 'invalid-verification-code':
  //         errorMsg = "Wrong OTP entered. Please check and try again.";
  //         break;
  //       case 'session-expired':
  //         errorMsg = "OTP has expired. Please resend a new OTP.";
  //         break;
  //       case 'invalid-verification-id':
  //         errorMsg = "Invalid session. Please restart the login process.";
  //         break;
  //       case 'too-many-requests':
  //         errorMsg = "Too many attempts. Please wait a while and try again.";
  //         break;
  //       case 'invalid-phone-number':
  //         errorMsg = "Invalid phone number. Please check your number.";
  //         break;
  //       case 'quota-exceeded':
  //         errorMsg = "SMS quota exceeded. Try again later.";
  //         break;
  //       default:
  //         errorMsg = e.message ?? "An unknown error occurred.";
  //     }
  //
  //     _showToast(errorMsg, toastColor);
  //     print("=======> OTP Message ${errorMsg}");
  //     // NO NAVIGATION on error
  //   } catch (e) {
  //     isLoading.value = false;
  //     String errorMsg = _getSmartErrorMessage(e.toString());
  //     _showToast(errorMsg, Colors.red);
  //     print("====> OTP Error: $e");
  //     throw e;
  //     // print("OTP Error: $e");
  //     // isLoading.value = false;
  //     // debugPrint("Unexpected Error: $e");
  //     // _showToast("Something went wrong. Please try again.", Colors.red);
  //     // NO NAVIGATION
  //   }
  // }
  //

  // NEW: Backend register after Firebase success (for register flow)
  // Future<void> _registerBackend(BuildContext context) async {
  //   try {
  //     final RegistrationController regController = Get.find<RegistrationController>();
  //     final Map<String, dynamic> body = {
  //       'CustomerName': regController.name.value,
  //       'CustomerEmailId': regController.email.value,
  //       'CustomerPhoneNo': phoneNumber.value,
  //       'CustomerFCMToken': tokenGet.value,
  //       'ReferCode': regController.refer.value,
  //       'FirmId': firmId  // Tera constant
  //     };
  //
  //     var response = await ApiService.post(endpoint: newAddCustomer, body: body);
  //     if (response.data['IsSuccess'] == true) {
  //       var data = response.data["Data"];
  //       if (data is List && data.isNotEmpty) {
  //         customerModel.value = CustomerModel.fromJson(data[0]);
  //         await helper.setCustomer(customerModel.value!);
  //         _showToast("Registration complete!", Colors.green);
  //       } else {
  //         _showToast("Registration failed: No data.", Colors.red);
  //       }
  //     } else {
  //       _showToast(response.data['Message'], Colors.red);
  //     }
  //   } catch (e) {
  //     _showToast("Backend registration failed: $e", Colors.red);
  //     throw e;
  //   }
  // }

  String _getSmartErrorMessage(String rawError) {
    String lowerError = rawError.toLowerCase();

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
  }

  // Helper method for custom toast (using fluttertoast for proper styling)
  void _showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM, // Center mein dikhe
      timeInSecForIosWeb: 3,
      backgroundColor: bgColor.withOpacity(0.9),
      textColor: Colors.white,
      fontSize: 16.0,
      webBgColor: bgColor == Colors.green
          ? "#4CAF50"
          : "#F44336", // Web support if needed
      webPosition: "center",
    );
  }

  Future<void> getToken(BuildContext context) async {
    if (phoneNumber.value.length == 10) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      isLoading.value = true;

      try {
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
          debugPrint('User granted permission');
          String? token = await messaging.getToken();
          if (token != null) {
            tokenGet.value = token;
            helper.getCustomer();
            // await submitPhoneNumber(token, context);
            debugPrint('FCM Token: $token');
          } else {
            debugPrint('Failed to get FCM token');
          }
        } else {
          debugPrint('User declined or has not accepted permission');
        }
      } catch (e) {
        debugPrint('Error getting token: $e');
        getFlutterToast("Failed to get notification token", Colors.red);
      } finally {
        isLoading.value = false;
      }
    } else {
      debugPrint('Enter a valid 10-digit mobile number');
    }
  }

  Future<void> signOut() async {
    await helper.deleteCustomer();
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().clearData();
    }
    customerModel.value = CustomerModel(); // Clear local state
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => LoginScreen());
  }
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
