import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:omkar_app/constant/app_constant.dart';
import 'package:omkar_app/view/otp/phone_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../constant/colorConst.dart';
import '../../controller/authController.dart';
import '../../controller/otpController.dart';
import '../../controller/registrationController.dart';
import '../../utils/services/firebase_authenticate.dart';
import '../../utils/string_res.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? registerPhoneNumber;
  final String? name;
  // final String? email;
  final String? referCode;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.registerPhoneNumber,
    this.name,
    // this.email,
    this.referCode,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final OTPController otpController = Get.put(OTPController(), permanent: true);
  final AuthController authController = Get.find();
  final RegistrationController registerController = Get.put(
    RegistrationController(),
  );
  FirebaseAuthenticate authenticate = FirebaseAuthenticate();
  final List<TextEditingController> otpFields = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // Add a single controller for the PinCodeTextField
  final TextEditingController pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isRegister = false;
    print("OTP Screen: Register Phone Number? ${widget.registerPhoneNumber}");
    isRegister = widget.registerPhoneNumber != "" ? true : false;
    print("OTP Screen: Is Register? $isRegister");
    return Scaffold(
      backgroundColor: COLOR.background,
      appBar: AppBar(
        title: Text(
          StringRes.enterVerificationCode,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: COLOR.appBaseColor,
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset( "assets/images/Enter_OTP-bro.png", height: MediaQuery.sizeOf(context).height * 0.6,
                //   width: MediaQuery.sizeOf(context).width * 0.4,),
                SvgPicture.asset(
                  "assets/images/Enter_OTP-bro1.svg",
                  height: MediaQuery.sizeOf(context).height * 0.4,
                  width: MediaQuery.sizeOf(context).width * 0.4,
                ),
                SizedBox(height: 20),
                Text(
                  StringRes.enterVerificationCode,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  StringRes.otpSentMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 20),
                PinCodeTextField(
                  keyboardType: TextInputType.number,
                  appContext: context,
                  length: 6,
                  cursorColor: COLOR.appBaseColor,
                  controller: pinController, // Use the persistent controller
                  onChanged: (value) {
                    if (value.length == 6) {
                      for (int i = 0; i < value.length && i < 6; i++) {
                        otpFields[i].text = value[i];
                      }
                      // otpController.verifyPhoneOtp(context, value, widget.phoneNumber ?? widget.registerPhoneNumber!);
                    }
                  },
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 45,
                    activeFillColor: Colors.white,
                    selectedFillColor: Colors.blue.shade50,
                    selectedColor: COLOR.appBaseColor.withOpacity(0.8),
                    inactiveFillColor: Colors.grey.shade200,
                    inactiveColor: Colors.black26,
                    activeColor: COLOR.appBaseColor.withOpacity(0.8),
                  ),
                ),

                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(StringRes.didntGetOtp),
                    SizedBox(width: 10),

                    Obx(() {
                      return otpController.isResendEnabled.value
                          ? TextButton(
                              onPressed: () {
                                otpController.resendOTP(
                                  context,
                                  widget.phoneNumber,
                                );
                              },
                              child: Text(StringRes.sendAgain),
                            )
                          : Opacity(
                              opacity: 0.4,
                              child: Text(StringRes.sendAgain),
                            );
                    }),

                    //       : SizedBox();
                    // }),
                    // GetBuilder<OTPController>(builder: (otpController) { return otpController.isResendEnabled.value ? TextButton(
                    //   onPressed: () {
                    //
                    //     // otpController.isResendEnabled.value
                    //     //     ?
                    //     otpController.resendOTP(context,widget.phoneNumber!);
                    //         // : false;
                    //   },
                    //   // otpController.isResendEnabled.value
                    //   //     ? otpController.resendOTP(context)
                    //   //     : null,
                    //   child: Text(StringRes.sendAgain),
                    // )
                    // : Opacity(child: Text(StringRes.sendAgain),opacity: 0.4,);}),
                    Spacer(),
                    Obx(() {
                      return Text(
                        "${otpController.secondsRemaining.value}s",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      );
                    }),
                  ],
                ),
                SizedBox(height: 10),
                Obx(
                  () => ElevatedButton(
                    // Disable button when loading
                    onPressed: otpController.isLoading.value
                        ? null
                        : () {
                            try {
                              String otp = pinController.text.trim();

                              if (otp.length == 6) {
                                // Set loading to prevent multiple clicks
                                otpController.isLoading.value = true;

                                if (isRegister &&
                                    widget.registerPhoneNumber != null) {
                                  otpController.verifyRegisterOtp(
                                    context,
                                    name: registerController.name.toString(),
                                    otp: otp,
                                    phoneNumber: widget.registerPhoneNumber
                                        .toString(),
                                    referCode: registerController.refer
                                        .toString(),
                                  );
                                } else {
                                  otpController.verifyLoginOtp(otp, context);
                                }
                              } else {
                                getFlutterToast(
                                  StringRes.phoneNumberMissing,
                                  Colors.red,
                                );
                              }
                            } catch (e) {
                              getFlutterToast(e.toString(), Colors.red);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: COLOR.appBaseColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    child: otpController.isLoading.value
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            StringRes.verifyOtp,
                            style: TextStyle(color: COLOR.background),
                          ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(LoginScreen());
                    print("Changing phone number...");
                  },
                  child: Text(StringRes.changeNumber),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
