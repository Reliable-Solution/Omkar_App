import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omkar_app/constant/colorConst.dart';
import 'package:omkar_app/controller/registrationController.dart';
import 'package:omkar_app/controller/otpController.dart';
import 'package:omkar_app/view/otp/phone_auth.dart';
import 'package:omkar_app/widget/buttonWidget.dart';
import '../../utils/string_res.dart';

class RegistrationScreen extends StatelessWidget {
  // final bool? isExpanded;
  // final bool? fromDeepLink;
  final String phone;

  RegistrationScreen({super.key, this.phone = ""});

  // RegistrationScreen(
  //     {super.key,this.phone
  //       // this.products, this.isExpanded, this.fromDeepLink
  //     });

  final RegistrationController controller = Get.put(RegistrationController());
  final OTPController otpController = Get.put(OTPController());

  final _formKey = GlobalKey<FormState>();

  void getNumber() {
    controller.phoneNumber.value = phone;
  }

  @override
  Widget build(BuildContext context) {
    if (controller.phoneNumber.value.isEmpty && phone.isNotEmpty) {
      controller.setPhoneNumber(phone);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          StringRes.register,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: COLOR.appBaseColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(StringRes.enterDetails, style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),

                TextFormField(
                  controller: controller.nameController,
                  autofillHints: [AutofillHints.name],
                  decoration: InputDecoration(
                    labelText: StringRes.name,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return StringRes.nameRequired;
                    if (value.length < 3) return StringRes.validName;
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Phone Number Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: StringRes.phoneNumber,
                    border: OutlineInputBorder(),
                  ),
                  controller: controller.phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return StringRes.mobileInvalid;
                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                      return StringRes.mobileRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: StringRes.referralCode,
                    border: OutlineInputBorder(),
                  ),
                  controller: controller.referController,
                ),

                SizedBox(height: 20),

                Obx(() {
                  return controller.isLoading.value
                      ? Center(
                          child: CircularProgressIndicator(
                            color: COLOR.appBaseColor,
                          ),
                        )
                      : Center(
                          child: ButtonWidgets(
                            voidCallback: () async {
                              if (_formKey.currentState!.validate()) {
                                controller.submitRegistration();
                              }
                            },
                            title: StringRes.register,
                            color: COLOR.appBaseColor,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                }),

                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: RichText(
                    text: TextSpan(
                      text: StringRes.agreeTerms,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(
                          text: StringRes.signIn,
                          style: TextStyle(
                            color: COLOR.appBaseColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.offAll(() => LoginScreen());
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
