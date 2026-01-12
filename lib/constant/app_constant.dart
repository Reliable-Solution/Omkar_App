import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:omkar_app/models/addressModel.dart';

String API_URL =
    // " ";
    "https://staging.ewaappliances.in//Admin/Ajax/";
// String API_URL = "https://keep.reliablesolution.in/Admin/Ajax/";
String IMAGE_URL =
    "https://staging.ewaappliances.in/resources/images/";
// String IMAGE_URL = "https://keep.reliablesolution.in/resources/images/";
String? firmId = "1";

getSnackbar(body, color) {
  Get.snackbar('Success', body, backgroundColor: color);
}

getFlutterToast(body, color) {
  Fluttertoast.showToast(msg: body, backgroundColor: color);
  // Get.snackbar(
  //   'Success',
  //   body,
  //   backgroundColor: color,
  // );
}

String getFullAddress(AddressModel selectedAddress) {
  String text(String? value) => (value?.isNotEmpty ?? false) ? "$value, " : '';
  return "${text(selectedAddress.addressColony)}${text(selectedAddress.cityName)}"
      "${text(selectedAddress.stateName)}${text(selectedAddress.addressPincode)}\n"
      "${(selectedAddress.addressMobileNo) ?? ''}";
}
