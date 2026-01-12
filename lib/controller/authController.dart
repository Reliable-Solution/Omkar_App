import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:omkar_app/constant/api_endpoints.dart';
import 'package:omkar_app/controller/otpController.dart';
import '../constant/app_constant.dart';
import '../models/customerModel.dart';
import '../utils/services/api_services.dart';
import '../utils/sharedPrefs.dart';
import '../view/dashboard/dashboardScreen.dart';
import '../view/otp/otp_screen.dart';
import '../view/otp/registrationScreen.dart';
import 'editController.dart';
import 'homeController.dart';

class AuthController extends GetxController {
  final phoneNumber = ''.obs;
  TextEditingController numberController = TextEditingController();
  final HomeController homeController = Get.find<HomeController>();
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

  void setRegisterFlow(bool value) {
    isRegisterFlow.value = value;
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
      debugPrint("✅ Name: ${customer.customerName}");
      debugPrint("=========> ✅ Name and Points: ${customer.points}");
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
        OTPController otpController = Get.put(OTPController());
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
      final Map<String, dynamic> body = {
        'CustomerPhoneNo': phoneNumber.value,
        "CustomerFCMToken": tokenGet.value,
      };
      var response = await ApiService.post(endpoint: login, body: body);
      isLoading.value = false;

      if (response.data['IsSuccess'] == true) {
        var data = response.data["Data"];
        if (data is List && data.isNotEmpty) {
          setRegisterFlow(false);
          customerModel.value = CustomerModel.fromJson(data[0]);
          await helper.setCustomer(customerModel.value!, "Auth controller");
          await sendFirebaseOTP(context); // Firebase for login
        } else {
          getFlutterToast("No account found. Please register.", Colors.black54);
          Get.offAll(() => RegistrationScreen(phone: phoneNumber.value));
        }
      } else {
        getFlutterToast(response.data['Message'], Colors.red);
      }
    } catch (e) {
      isLoading.value = false;
      getFlutterToast("Failed to login. Try again.", Colors.red);
    }
  }

  // Shared: Firebase OTP send (login/register dono ke liye)
  Future<void> sendFirebaseOTP(BuildContext context) async {
    isLoading.value = true;
    update();
    String fullPhone = '$dialCode${phoneNumber.value}';

    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: fullPhone,
      verificationCompleted: (credential) async {
        await firebaseAuth.signInWithCredential(credential);
        isLoading.value = false;
        getFlutterToast("Auto login successful!", Colors.green);
      },
      verificationFailed: (e) {
        isLoading.value = false;
        debugPrint("Verification Failed: ${e.message}");

        getFlutterToast(e.message ?? "OTP send failed.", Colors.red);
      },
      codeSent: (verId, resendToken) {
        verificationId.value = verId;
        isLoading.value = false;
        Get.to(
          () => OTPVerificationScreen(
            phoneNumber: phoneNumber.value,
            registerPhoneNumber: isRegisterFlow.value ? phoneNumber.value : "",
          ),
        );
        OTPController otpController = Get.put(OTPController());
        otpController.startTimer();
        getFlutterToast("OTP sent.", Colors.green);
      },
      codeAutoRetrievalTimeout: (verId) => verificationId.value = verId,
      timeout: const Duration(seconds: 60),
    );
  }

  // Login: Post Firebase success work (customer fetch etc.)
  Future<void> completeLogin() async {
    if (customerModel.value == null) {
      throw Exception("Customer data missing.");
    }
    editProfileController.GetProfile(
      customerId: customerModel.value!.customerId!,
    );
    homeController.getPrefs();
    homeController.getDashboardData(customerModel.value?.customerId);
    getFlutterToast("Login Successful", Colors.green.shade900);
    Future.delayed(const Duration(seconds: 1), () {
      Get.offAll(() => DashboardScreen(pageIndex: 0));
    });
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
