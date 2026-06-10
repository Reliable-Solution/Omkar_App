// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:omkar_app/controller/homeController.dart';
// import 'package:omkar_app/utils/sharedPrefs.dart';
// import 'package:omkar_app/view/account/editProfile.dart';
// import 'package:omkar_app/view/account/primary.dart';
// import 'package:omkar_app/view/account/profile_screen.dart';
// import 'package:omkar_app/view/account/widget/accountList.dart';
// import 'package:omkar_app/view/address/pickupAddressScreen.dart';
// import 'package:omkar_app/view/faq/faq_screen.dart';
// import 'package:omkar_app/view/order/orderScreen.dart';
// import 'package:omkar_app/view/raise%20ticket/create_ticket.dart';
// import 'package:omkar_app/view/raise%20ticket/ticketMainScreen.dart';
// import 'package:omkar_app/view/webView/webView_screen.dart';
// import '../../Theme/nativeTheme.dart';
// import '../../constant/colorConst.dart';
// import '../../constant/imagesConst.dart';
// import '../../controller/accountController.dart';
// import '../../utils/services/firebase_authenticate.dart';
// import '../../utils/services/languageServices.dart';
// import '../../utils/string_res.dart';
// import '../../widget/alignWidget.dart';
// import '../../widget/appBarWidget.dart';
// import '../../widget/buttonWidget.dart';
// import '../../widget/dividerWidgets.dart';
// import '../../widget/iconButtonWidget.dart';
// import '../../widget/languageWidget.dart';
// import '../../widget/textWidget.dart';
// import '../address/allAddress_screen.dart';
// import '../otp/OTPVerificationForm.dart';
// import '../otp/phone_auth.dart';
// import '/utils/global.dart' as global;

// class AccountScreen extends StatefulWidget {
//   const AccountScreen({super.key});

//   @override
//   State<AccountScreen> createState() => _AccountScreenState();
// }

// class _AccountScreenState extends State<AccountScreen> {
//   FirebaseAuthenticate authenticate = FirebaseAuthenticate();
//   TextEditingController txtNumber = TextEditingController();
//   TextEditingController txtMsg = TextEditingController();
//   AccountController controller = AccountController();
//   final HomeController _controller = Get.find<HomeController>();

//   String? fcmToken;

//   @override
//   Widget build(BuildContext context) {
//     print(" name ${_controller.customerModel!.value.customerName}");
//     return Scaffold(
//       backgroundColor: COLOR.greyLight,
//       appBar: MyCustomAppBar(
//         // leading: SizedBox(),
//         action: [],
//         actionPadding: 10,
//         height: 90,
//         appbarPadding: 0,
//         text: StringRes.account,
//         elevation: 1,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             Padding(
//               padding: EdgeInsets.only(top: 4),
//               child: Container(
//                 color: COLOR.background,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     Padding(
//                       padding: EdgeInsets.only(right: 18),
//                       child: CircleAvatar(
//                         maxRadius: 31,
//                         backgroundImage: AssetImage(Images.profileicon),
//                         backgroundColor: COLOR.greyLight,
//                       ),
//                     ),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Obx(
//                             () => Text(
//                               _controller.customerModel != null
//                                   ? "${StringRes.hello} ${_controller.customerModel!.value.customerName}"
//                                   : "${StringRes.hello}",
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.only(top: 5),
//                             child: TextWiget(
//                                 title: StringRes.viewProfile,
//                                 style: Themes.light.textTheme.displaySmall),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: AlignWidget(
//                         alignment: Alignment.centerRight,
//                         child: IconButtonWidget(
//                           voidCallback: () {
//                             Get.to(
//                               () => EditProfileScreen(),
//                               transition: Transition.rightToLeftWithFade,
//                             );
//                           },
//                           icons: Icons.navigate_next_outlined,
//                           size: 35,
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 10),
//               child: AccountList(),
//             ),
//             Padding(
//               padding: EdgeInsets.only(top: 06),
//               child: Container(
//                 height: MediaQuery.of(context).size.height * 0.14,
//                 color: COLOR.background,
//                 // margin: EdgeInsets.all(10),
//                 padding: EdgeInsets.all(10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     changeLanguageButton(() {
//                       showLanguageBottomSheet(context);
//                     }),
//                     buildAddAddressButton(
//                       onTap: () {
//                         Get.to(
//                           () => AllAddressScreen(),
//                           transition: Transition.rightToLeftWithFade,
//                         );
//                         print("Add Address Clicked!");
//                         // Navigate to Add Address Screen
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(top: 04),
//               child: InkWell(
//                 onTap: () {
//                   // Get.to(WebViewScreen(url: 'https://flutter.dev/'));
//                   Get.to(
//                     Orderscreen(),
//                     transition: Transition.rightToLeftWithFade,
//                   );
//                 },
//                 child: Container(
//                   height: MediaQuery.of(context).size.height * 0.06,
//                   color: COLOR.background,
//                   // margin: EdgeInsets.all(10),
//                   padding: EdgeInsets.all(10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         StringRes.orders,
//                         style: Themes.light.textTheme.displayLarge!,
//                       ),
//                       Icon(Icons.shopping_bag),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(top: 04),
//               child: InkWell(
//                 onTap: () {
//                   Get.to(
//                     FaqScreen(),
//                     transition: Transition.rightToLeftWithFade,
//                   );
//                 },
//                 child: Container(
//                   height: MediaQuery.of(context).size.height * 0.06,
//                   color: COLOR.background,
//                   // margin: EdgeInsets.all(10),
//                   padding: EdgeInsets.all(10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         StringRes.faq,
//                         style: Themes.light.textTheme.displayLarge!,
//                       ),
//                       Icon(Icons.help),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(top: 04),
//               child: InkWell(
//                 onTap: () {
//                   // Get.to(CreateComplainScreen());
//                   Get.to(
//                     TicketMainScreen(),
//                     transition: Transition.rightToLeftWithFade,
//                   );
//                 },
//                 child: Container(
//                   height: MediaQuery.of(context).size.height * 0.06,
//                   color: COLOR.background,
//                   // margin: EdgeInsets.all(10),
//                   padding: EdgeInsets.all(10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         StringRes.raiseTicket,
//                         // "Raise A Ticket",
//                         style: Themes.light.textTheme.displayLarge!,
//                       ),
//                       Icon(Icons.question_answer),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(top: 04),
//               child: InkWell(
//                 onTap: () {
//                   _showDeleteBottomSheet(context);
//                   // _showLogoutBottomSheet(context);
//                 },
//                 child: Container(
//                   height: MediaQuery.of(context).size.height * 0.06,
//                   color: COLOR.background,
//                   // margin: EdgeInsets.all(10),
//                   padding: EdgeInsets.all(10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         StringRes.deleteAccount,
//                         style: Themes.light.textTheme.displayLarge!,
//                       ),
//                       Icon(Icons.delete),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             // Padding(
//             //   padding: EdgeInsets.only(top: 04),
//             //   child: InkWell(
//             //     onTap: () {
//             //       _showLogoutBottomSheet(context);
//             //     },
//             //     child: Container(
//             //       height: MediaQuery.of(context).size.height * 0.06,
//             //       color: COLOR.background,
//             //       // margin: EdgeInsets.all(10),
//             //       padding: EdgeInsets.all(10),
//             //       child: Row(
//             //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //         children: [
//             //           Text(
//             //             StringRes.logout,
//             //             style: Themes.light.textTheme.displayLarge!,
//             //           ),
//             //           Icon(Icons.logout),
//             //         ],
//             //       ),
//             //     ),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildAddAddressButton({required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 35),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade50,
//           border: Border.all(color: Colors.grey, width: 0.5),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.location_on, color: Color(0xff226706), size: 30),
//             SizedBox(height: 5),
//             Text(
//               StringRes.addAddress,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget changeLanguageButton(VoidCallback onTap) {
//     return Material(
//       color: Colors.transparent, // Transparent background for ripple effect
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         // Ripple effect ke liye
//         splashColor: COLOR.appBaseColor.withOpacity(0.2),
//         // Ripple ka color
//         highlightColor: COLOR.appBaseColor.withOpacity(0.1),
//         // Button press effect
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade50,
//             border: Border.all(color: Colors.grey, width: 0.5),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   Icon(Icons.language, size: 30, color: COLOR.appBaseColor),
//                   Positioned(
//                     top: -5,
//                     right: -5,
//                     child: Container(
//                       padding: const EdgeInsets.all(3),
//                       decoration: BoxDecoration(
//                         color: COLOR.appBaseColor,
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             "अ",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(width: 2),
//                           Text(
//                             "A",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 5),
//               Text(
//                 StringRes.changeLanguage,
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void openBottomSheetSignup(BuildContext context) {
//     Get.bottomSheet(
//       Container(
//         height: MediaQuery.of(context).size.height * 0.55,
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(bottom: 5),
//               child: AlignWidget(
//                 alignment: Alignment.topRight,
//                 child: IconButtonWidget(
//                   voidCallback: () {
//                     Get.back();
//                   },
//                   icons: Icons.close,
//                 ),
//               ),
//             ),
//             AlignWidget(
//               alignment: Alignment.centerLeft,
//               child: TextWiget(
//                 title: "",
//                 style: Themes.light.textTheme.displayLarge!.copyWith(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.2,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   CountryCodePicker(
//                     initialSelection: 'IN',
//                     showCountryOnly: false,
//                     barrierColor: COLOR.black,
//                     backgroundColor: COLOR.background,
//                     boxDecoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       color: COLOR.black,
//                     ),
//                     showOnlyCountryWhenClosed: false,
//                     favorite: ['+91', 'IN '],
//                   ),
//                   SizedBox(width: 8.0),
//                   Expanded(
//                     child: TextField(
//                       decoration: InputDecoration(
//                         isDense: true,
//                         counterText: '',
//                         contentPadding: EdgeInsets.zero,
//                       ),
//                       maxLength: 10,
//                       keyboardType: TextInputType.number,
//                       controller: txtNumber,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(top: 5),
//               child: SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.07,
//                 width: MediaQuery.of(context).size.width,
//                 child: ButtonWidgets(
//                   voidCallback: () {
//                     openBottomSheetOTP(context);
//                     authenticate.onVerifyCode(txtNumber.text);
//                     onTap();
//                   },
//                   color: COLOR.appBaseColor,
//                   style: Themes.light.textTheme.displaySmall!.copyWith(
//                     color: COLOR.background,
//                   ),
//                   title: StringRes.otp,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   TextWiget(
//                     title: "${StringRes.continuingAgree} ${global.appname}",
//                     style: Themes.dark.textTheme.displayLarge,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       TextWiget(
//                         title: StringRes.termsConditions,
//                         style: Themes.dark.textTheme.displayLarge!.copyWith(
//                           color: COLOR.appBaseColor,
//                         ),
//                       ),
//                       TextWiget(
//                         title: StringRes.and,
//                         style: Themes.dark.textTheme.displayLarge,
//                       ),
//                       TextWiget(
//                         title: StringRes.privacyPolicy,
//                         style: Themes.dark.textTheme.displayLarge!.copyWith(
//                           color: COLOR.appBaseColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       isScrollControlled: true,
//       backgroundColor: COLOR.background,
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(10),
//           topRight: Radius.circular(10),
//         ),
//       ),
//     );
//   }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/colorConst.dart';
import '../../constant/imagesConst.dart';
import '../../controller/homeController.dart';
import '../../controller/authController.dart';

import '../../utils/string_res.dart';
import '../../utils/sharedPrefs.dart';

import '../address/allAddress_screen.dart';
import '../faq/faq_screen.dart';

import '../raise ticket/ticketMainScreen.dart';
import 'editProfile.dart';
import 'qr_scanner_view.dart';
import '../../constant/app_constant.dart';
import '../scan_history/scan_history_screen.dart';
import '../redeem/withdraw_point_screen.dart';

void _showLogoutBottomSheet(BuildContext context) {
  Get.bottomSheet(
    SafeArea(
      bottom: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              StringRes.logoutConfirmation,

              // "Are you sure you want to logout?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(StringRes.cancel, style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: COLOR.appBaseColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    AuthController authController = Get.put(AuthController());
                    await authController.signOut();
                  },
                  child: Text(StringRes.logout, style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    isDismissible: true,
    enableDrag: true,
    enterBottomSheetDuration: Duration(milliseconds: 300),
    exitBottomSheetDuration: Duration(milliseconds: 300),
  );
}

void _showDeleteBottomSheet(BuildContext context) {
  Get.bottomSheet(
    SafeArea(
      bottom: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              StringRes.deleteAccountConfirmation,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(StringRes.cancel, style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    SharedHelper helper = SharedHelper();
                    await helper.deleteCustomer();
                    await helper.storeBool(
                      value: true,
                      key: SharedHelper.deleteAccountKey,
                    );
                    AuthController authController = Get.find<AuthController>();
                    await authController.signOut();
                    Get.showSnackbar(
                      GetSnackBar(
                        message: StringRes.accountDeleted,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  child: Text(StringRes.delete, style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    isDismissible: true,
    enableDrag: true,
    enterBottomSheetDuration: Duration(milliseconds: 300),
    exitBottomSheetDuration: Duration(milliseconds: 300),
  );
}

//   void openBottomSheetOTP(BuildContext context) {
//     Get.bottomSheet(
//       Container(
//         height: MediaQuery.of(context).size.height * 0.55,
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Container(
//                   child: IconButtonWidget(
//                     voidCallback: () {},
//                     icons: Icons.navigate_before,
//                   ),
//                 ),
//                 TextWiget(
//                   title: StringRes.changeNumber,
//                   style: Themes.light.textTheme.displaySmall!.copyWith(
//                     color: COLOR.black,
//                   ),
//                 ),
//                 Expanded(
//                   child: AlignWidget(
//                     alignment: Alignment.topRight,
//                     child: IconButtonWidget(
//                       voidCallback: () {
//                         Get.back();
//                       },
//                       icons: Icons.close,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 5, bottom: 5),
//               child: AlignWidget(
//                 alignment: Alignment.centerLeft,
//                 child: TextWiget(
//                   title: StringRes.enterOtp,
//                   style: Themes.dark.textTheme.headlineMedium,
//                 ),
//               ),
//             ),
//             AlignWidget(
//               alignment: Alignment.centerLeft,
//               child: TextWiget(
//                 title: StringRes.changeNumber,
//                 style: Themes.light.textTheme.displaySmall!.copyWith(
//                   color: COLOR.appBaseColor,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             // Container(
//             //   height: MediaQuery.of(context).size.height * 0.15,
//             //   child: OTPVerificationForm(),
//             // ),
//             Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: TextWiget(style: Themes.light.textTheme.headlineMedium),
//             ),
//             SizedBox(height: 5),
//             Expanded(
//               child: Container(
//                 alignment: Alignment.center,
//                 child: SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.07,
//                   width: MediaQuery.of(context).size.width,
//                   child: ButtonWidgets(
//                     voidCallback: () {
//                       authenticate.onFormSubmited(controller.message.value!);
//                     },
//                     color: COLOR.appBaseColor,
//                     style: Themes.light.textTheme.displaySmall!.copyWith(
//                       color: COLOR.background,
//                     ),
//                     title: StringRes.verify,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       isScrollControlled: true,
//       backgroundColor: COLOR.background,
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(10),
//           topRight: Radius.circular(10),
//         ),
//       ),
//     );
//   }

//   void onTap() {
//     print("==================== token1 $fcmToken");
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:omkar_app/Theme/nativeTheme.dart'; // assuming your theme
// import 'package:omkar_app/constant/colorConst.dart';
// import 'package:omkar_app/constant/imagesConst.dart';
// import 'package:omkar_app/controller/homeController.dart';
// import 'package:omkar_app/utils/string_res.dart';
// import 'package:omkar_app/view/account/editProfile.dart';
// import 'package:omkar_app/view/account/widget/accountList.dart'; // if you still need it
// import 'package:omkar_app/view/address/allAddress_screen.dart';
// import 'package:omkar_app/view/faq/faq_screen.dart';
// import 'package:omkar_app/view/order/orderScreen.dart';
// import 'package:omkar_app/view/raise%20ticket/ticketMainScreen.dart';
// ... other imports you need

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        backgroundColor: COLOR.appBaseColor,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black87),
        //   onPressed: () => Get.back(),
        // ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: COLOR.background,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        // centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Profile Header ────────────────────────────────
            Column(
              children: [
                SizedBox(height: 20),
                // Circular avatar with nice ring effect
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            COLOR.appBaseColor,
                            COLOR.appBaseColor.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Obx(
                      () => CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 47,
                          backgroundColor: COLOR.greyLight,
                          backgroundImage:
                              (controller.customerModel?.value.customerImage !=
                                      null &&
                                  controller
                                      .customerModel!
                                      .value
                                      .customerImage!
                                      .isNotEmpty)
                              ? NetworkImage(
                                      controller
                                              .customerModel!
                                              .value
                                              .customerImage!
                                              .startsWith('http')
                                          ? controller
                                                .customerModel!
                                                .value
                                                .customerImage!
                                          : "$IMAGE_URL${controller.customerModel!.value.customerImage}",
                                    )
                                    as ImageProvider
                              : AssetImage(Images.profileicon),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Obx(
                  () => Text(
                    controller.customerModel?.value.customerName ??
                        "Guest User",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Obx(
                  () => Text(
                    controller.customerModel?.value.customerPhoneNo ??
                        "Not Available",
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  ),
                ),

                const SizedBox(height: 4),

                // Text(
                //   controller.customerModel?.value.customerEmailId ??
                //       "example@email.com",
                //   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                // ),
                const SizedBox(height: 20),

                // Edit Profile Button
                OutlinedButton.icon(
                  onPressed: () async {
                    await Get.to(
                      () => EditProfileScreen(),
                      transition: Transition.rightToLeftWithFade,
                    );
                    await controller.getPrefs(); // Reload data on return
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text("Edit Profile"),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: COLOR.appBaseColor),
                    foregroundColor: COLOR.appBaseColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ── Menu Items ─────────────────────────────────────
            // _buildMenuTile(
            //   icon: Icons.receipt_long_outlined,
            //   title: StringRes.orders ?? "Order History",
            //   onTap: () => Get.to(
            //     () => Orderscreen(),
            //     transition: Transition.rightToLeftWithFade,
            //   ),
            //   context: context,
            // ),

            // SizedBox(child: Divider(color: Colors.black12,height: 0.5,),width: MediaQuery.sizeOf(context).width * 0.9,),
            // _buildMenuTile(
            //   icon: Icons.location_on_outlined,
            //   title: "Shipping Address",
            //   onTap: () => Get.to(
            //     () => AllAddressScreen(),
            //     transition: Transition.rightToLeftWithFade,
            //   ),
            //   context: context,
            // ),

            // Obx(
            //   () => controller.customerModel?.value.role == "carpenter"
            //       ? Column(
            //           children: [
            //             _buildMenuTile(
            //               icon: Icons.barcode_reader,
            //               title: "Barcode Scan",
            //               onTap: () async {
            //                 await Get.to(
            //                   () => const QRScannerView(),
            //                   transition: Transition.rightToLeftWithFade,
            //                 );
            //               },
            //               context: context,
            //             ),
            //             _buildMenuTile(
            //               icon: Icons.history_rounded,
            //               title: "Scan History",
            //               onTap: () => Get.to(
            //                 () => const ScanHistoryScreen(),
            //                 transition: Transition.rightToLeftWithFade,
            //               ),
            //               context: context,
            //             ),
            //           ],
            //         )
            //       : const SizedBox(),
            // ),
            // _buildMenuTile(
            //   icon: Icons.account_balance_wallet_outlined,
            //   title: "Withdraw Points",
            //   onTap: () => Get.to(
            //     () => const WithdrawPointScreen(),
            //     transition: Transition.rightToLeftWithFade,
            //   ),
            //   context: context,
            // ),
            _buildMenuTile(
              icon: Icons.question_answer_outlined,
              title: "FAQ",
              onTap: () => Get.to(
                () => FaqScreen(),
                transition: Transition.rightToLeftWithFade,
              ),
              context: context,
            ),

            _buildMenuTile(
              icon: Icons.support_agent_outlined,
              title: StringRes.raiseTicket ?? "Create Request",
              onTap: () => Get.to(
                () => TicketMainScreen(),
                transition: Transition.rightToLeftWithFade,
              ),
              context: context,
            ),

            _buildMenuTile(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              onTap: () {
                // WebViewScreen(url: "your_privacy_policy_url")
              },
              context: context,
            ),

            // _buildMenuTile(
            //   icon: Icons.settings_outlined,
            //   title: "Settings",
            //   onTap: () {
            //     // Settings screen ya language bottom sheet
            //     // showLanguageBottomSheet(context);
            //   },
            //   context: context,
            // ),
            _buildMenuTile(
              icon: Icons.logout,
              title: "Log out",
              color: Colors.grey.shade700,
              onTap: () {
                _showLogoutBottomSheet(context);
                // Get.snackbar("Logout", "Coming soon...");
              },
              context: context,
            ),

            _buildMenuTile(
              icon: Icons.delete_forever_outlined,
              title: StringRes.deleteAccount,
              color: Colors.red.shade700,
              onTap: () {
                _showDeleteBottomSheet(context);
              },
              context: context,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 4, // assuming Profile is last tab
      //   selectedItemColor: COLOR.appBaseColor,
      //   unselectedItemColor: Colors.grey,
      //   showSelectedLabels: false,
      //   showUnselectedLabels: false,
      //   type: BottomNavigationBarType.fixed,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home_outlined),
      //       label: "Home",
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.grid_view),
      //       label: "Categories",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_cart_outlined),
      //       label: "Cart",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person_outline),
      //       label: "Profile",
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required BuildContext context,

    Color? color,
  }) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: COLOR.appBaseColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color ?? Colors.grey.shade700, size: 26),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.95,
          child: Divider(color: Colors.black12, height: 0.5),
        ),
      ],
    );
  }
}
