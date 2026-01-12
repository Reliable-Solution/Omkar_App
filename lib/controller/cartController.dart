import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:omkar_app/controller/homeController.dart';
import 'package:omkar_app/models/getCartTotalModel.dart';

import '../constant/api_endpoints.dart';
import '../constant/app_constant.dart';
import '../models/cartDetailModel.dart';
import '../models/customerModel.dart';
import '../models/productModel.dart';
import '../utils/services/api_services.dart';
import '../utils/services/services.dart';
import '../utils/sharedPrefs.dart';
import 'networkController.dart';

class CartController extends GetxController {
  NetworkController networkController = Get.put(NetworkController());
  final HomeController homeController = Get.find<HomeController>();

  // HomeController homeController = Get.put(HomeController());
  Rx<CustomerModel>? customerModel = CustomerModel().obs;

  // Rx<CartTotal?> cartTotal = Rx<CartTotal?>(null);
  final Rx<CartTotal> cartTotal = CartTotal().obs;
  RxList<CartDetailModel> cartList = <CartDetailModel>[].obs;
  RxInt cartCount = 0.obs;
  RxBool isUpdateLoading = false.obs;
  RxBool isCartRemoveLoading = false.obs;
  RxBool isCartCheck = false.obs;

  var isReadMore = false;
  RxBool isCartLoading = false.obs;
  final TextEditingController redeemPointsController = TextEditingController();

  @override
  void onInit() async {
    getPrefs();
    super.onInit();
  }

  getPrefs() async {
    SharedHelper helper = SharedHelper();

    CustomerModel? customer = await helper.getCustomer();
    if (customer != null) {
      customerModel!.value = customer;
      print(
        "Pro"
        ""
        "duct Detail Screen ${customerModel!.value.customerName}",
      );
      // await Future.delayed(Duration(seconds: 10)); // ⏳ delay for 2 seconds

      getCartDetails(customer.customerId!);
      getCartTotal(customer.customerId!);
    }
    update();
  }

  updateCartTotal(CartTotal value) {
    cartTotal.value = value;
    update();
  }

  Future<void> getCartDetails(String customerID) async {
    // isCartLoading.value = true;

    // cartList.clear();
    // // await Future.delayed(Duration(seconds: 2)); // ⏳ delay for 2 seconds

    // try {
    //   final Map<String, dynamic> body = {
    //     'CustomerId': customerID,
    //     'FirmId': firmId,
    //   };

    //   var response = await ApiService.post(
    //     endpoint: getCartDetailApi,
    //     body: body,
    //   );

    //   if (response.data['IsSuccess'] == true) {
    //     var data = response.data['Data'];

    //     print("API Response: ${response.data}");
    //     if (data[0]['Cart'] != null) {
    //       cartList.value = (data[0]['Cart'] as List)
    //           .map((productJson) => CartDetailModel.fromJson(productJson))
    //           .toList();
    //     }
    //     isCartLoading.value = false;
    //     update();
    //   } else {
    //     throw Exception("Error from API: ${response.data['Message']}");
    //   }
    // } catch (e) {
    //   print("Failed to fetch cart: $e");
    //   getFlutterToast("Failed to fetch cart.", Colors.red);
    // } finally {
    //   isCartLoading.value = false;
    // }
  }

  Future<void> updateCartQty(String cartID, String cartQuantity) async {
    try {
      final Map<String, dynamic> body = {
        'CartId': cartID,
        'CartQuantity': cartQuantity,
        'FirmId': firmId,
      };

      var response = await ApiService.post(
        endpoint: updateCartQtyApi,
        body: body,
      );
      if (response.data['IsSuccess'] == true) {
        getCartTotal(customerModel!.value.customerId!);
        update();
      } else {
        throw Exception("Error from API: ${response.data['Message']}");
      }
    } catch (e) {
      print("Error in Cart: $e");
      throw Exception("Failed to update cart data: $e");
    }
  }

  Future<void> removeFromCart({required String cartID}) async {
    try {
      final Map<String, dynamic> body = {'CartId': cartID, 'FirmId': firmId};

      var response = await ApiService.post(endpoint: removeCartApi, body: body);

      if (response.data['IsSuccess'] == true) {
        // homeController.getDashboardData(customerModel!.value.customerId);
        getCartTotal(customerModel!.value.customerId!);
        update();
      } else {
        throw Exception("Error from API: ${response.data['Message']}");
      }
    } catch (e) {
      print("Error in Cart: $e");
      throw Exception("Failed to remove cart data: $e");
    }
  }

  bool isApplyLoad = false;

  Future<void> getCartTotal(customerID, {bool isApplyCall = false}) async {}
}
