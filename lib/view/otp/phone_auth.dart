import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omkar_app/utils/string_res.dart';
import 'package:omkar_app/controller/otpController.dart';
import 'package:omkar_app/view/otp/addUserScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/authController.dart';
import '../../controller/languageController.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/colorConst.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController controller = Get.put(AuthController());

  final OTPController otpController = Get.put(OTPController(), permanent: true);

  TextEditingController txtNumber = TextEditingController();

  TextEditingController txtPhoneNumber = TextEditingController();

  TextEditingController txtOtpNumber = TextEditingController();

  final AuthController authController = Get.put(AuthController());

  final _formKey = GlobalKey<FormState>();

  final LanguageController languageController = Get.find<LanguageController>();

  final RxString selectedLangName = "ગુજરાતી".obs;
  bool isAcceptedTerms = false;

  Future<void> getData() async {
    SharedPreferences helper = await SharedPreferences.getInstance();
    helper.getString("languageName");
    print(
      "Language ==========> Language Name ${helper.getString("languageName")}",
    );
    print("Language ==========> Language Name ${helper.getString("language")}");
    String? name = helper.getString("languageName");
    setState(() {
      print("=============> NAME IS LOGIN $name");
      selectedLangName.value = name ?? "ગુજરાતી";
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    languageController.loadLanguage();
    getData();
    // SharedPreferences helper = SharedPreferences.getInstance();
    // helper.getString("languageName");
    languageController.languageName;
    if (languageController.languageName.value.isEmpty) {
      selectedLangName.value = "ગુજરાતી";
      languageController.changeLanguage("ગુજરાતી");
    } else {
      languageController.languageName.value == "gu"
          ? selectedLangName.value = "ગુજરાતી"
          : languageController.languageName == "hi"
          ? selectedLangName.value = "हिंदी"
          : selectedLangName.value = "English";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("===========> Selected Language ${selectedLangName.value}");
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   automaticallyImplyLeading: false, // Removes the back button
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Logo Section
              Center(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
                    Image.asset(
                      "assets/images/logo.png",
                      height: 180, // Made it prominent
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.eco_outlined,
                        size: 80,
                        color: COLOR.appBaseColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.035),
              Text(
                StringRes.login,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Phone Input Section
              RichText(
                text: TextSpan(
                  text: "${StringRes.phone} ",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    TextSpan(
                      text: "*",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: txtNumber,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, bottom: 16),
                      child: Text(
                        "+91 ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    counterText: "",
                    hintText: StringRes.enterYourPhoneNumber,
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: COLOR.appBaseColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) {
                    controller.setPhoneNumber(value);
                    controller.update();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return StringRes.mobileRequired;
                    }
                    if (value.length != 10) {
                      return StringRes.mobileInvalid;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Terms and Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: isAcceptedTerms,
                    activeColor: COLOR.appBaseColor,
                    onChanged: (value) {
                      setState(() {
                        isAcceptedTerms = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "I Agree with all the ",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: "Terms & Conditions",
                            style: TextStyle(
                              color: COLOR.appBaseColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final Uri url = Uri.parse(
                                  'https://staging.ewaappliances.in/privacy_policy',
                                );
                                if (!await launchUrl(url)) {
                                  Get.snackbar(
                                    "Error",
                                    "Could not launch terms and conditions",
                                  );
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 32),
              // Login Button
              Obx(
                () => controller.isLoading.value
                    ? Center(
                        child: CircularProgressIndicator(
                          color: COLOR.appBaseColor,
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          // Disable button when loading
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                      if (!isAcceptedTerms) {
                                        snackBarMessengers(
                                          context,
                                          message: "Please accept Terms & Conditions to proceed",
                                        );
                                        return;
                                      }
                                    // Set loading to prevent multiple clicks
                                    controller.isLoading.value = true;
                                    await authController.getToken(context);
                                    await controller.sendOTPPhone(context);
                                    // isLoading will be reset in sendOTPPhone
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: COLOR.appBaseColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            StringRes.login,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              // Footer
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have account? ",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                    children: [
                      TextSpan(
                        text: StringRes.signUp,
                        style: TextStyle(
                          color: COLOR.appBaseColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(() => AddUserScreen());
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              /* 
              // OLD UI CODE COMMENTED BELOW
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/banner.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GetBuilder<LanguageController>(
                            builder: (languageController) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildLangChip("ગુજરાતી", selectedLangName.value == "ગુજરાતી", () async {...}),
                                  _buildLangChip("हिंदी", selectedLangName.value == "हिंदी", () {...}),
                                  _buildLangChip("English", selectedLangName.value == "English", () {...}),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(StringRes.login, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          TextFormField(controller: txtNumber, ...),
                          SizedBox(height: 215),
                          Center(child: Obx(() => ...)),
                          SizedBox(height: 10),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0), child: RichText(...)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              */
            ],
          ),
        ),
      ),
    );
  }
}
