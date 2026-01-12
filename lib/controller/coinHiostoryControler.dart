import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:omkar_app/constant/app_constant.dart';

import '../constant/api_endpoints.dart';
import '../models/coinHistoryModel.dart';
import '../models/customerModel.dart';
import '../utils/services/api_services.dart';
import '../utils/sharedPrefs.dart';

class CoinHistoryController extends GetxController {
  List<CoinHistoryModel> historyList =
      <CoinHistoryModel>[].obs; // Observable list
  var isLoading = true.obs; // For loading state if needed
  SharedHelper helper = SharedHelper();
  Rx<CustomerModel>? customerModel = CustomerModel().obs;
  String customerId = "";

  @override
  void onInit() {
    super.onInit();
    getData();
    fetchHistory(
      customerId: customerModel?.value.customerId ?? "",
    ); // Simulate fetching data
  }

  Future<void> getData() async {
    try {
      isLoading(true); // Optional: show loading while getting customer
      CustomerModel? customer = await helper.getCustomer();
      if (customer != null &&
          customer.customerId != null &&
          customer.customerId!.isNotEmpty) {
        customerModel?.value = customer;
        customerId = customer.customerId!;
        debugPrint("✅ Id: $customerId");
        await fetchHistory(
          customerId: customerId,
        ); // Await to ensure sequential
      } else {
        debugPrint("❌ Customer ID not found or invalid");
        // Get.snackbar('Error', 'Customer ID not available');
        // Optionally handle no customer: redirect to login etc.
      }
    } catch (e) {
      debugPrint("Exception in getData: $e");
      // Get.snackbar('Error', 'Failed to load customer data');
    } finally {
      isLoading(false);
    }
    // CustomerModel? customer = await helper.getCustomer();
    // if (customer != null) {
    //   customerModel!.value = customer;
    //   customerId = customerModel?.value.customerId ?? "";
    //   fetchHistory(customerId: customerId);
    //   debugPrint("✅ Id: ${customer.customerId}");
    //   update(); // agar tu GetBuilder bhi use kar raha hai
    // }
  }

  Future<void> fetchHistory({required String customerId}) async {
    if (customerId.isEmpty) {
      debugPrint("CustomerId is empty, skipping API call");
      // Get.snackbar('Error', 'Customer ID is required');
      isLoading(false);
      return;
    }
    try {
      isLoading(true);
      final Map<String, dynamic> body = {'CustomerId': customerId};

      // Make the API call
      var response = await ApiService.post(endpoint: get_history, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(
          "{   \"english\": \"Refer your friend you will get Rs 100 and your friend will get Rs 100\",   \"hindi\": \"अपने दोस्त को रेफर करें, आपको ₹100 मिलेगा और आपके दोस्त को भी ₹100 मिलेगा\",   \"gujarati\": \"તમારા મિત્રને રેફર કરો, તમને ₹100 મળશે અને તમારા મિત્રને પણ ₹100 મળશે\",   \"marathi\": \"तुमच्या मित्राला रेफર करा, तुम्हाला ₹100 मिळेल आणि तुमच्या मित्रालाही ₹100 मिळेल\" }",
        );
        print("========> Json Decode ${data}");
        var jsonResponse;
        if (response.data is String) {
          jsonResponse = json.decode(response.data); // Parse String to Map
        } else if (response.data is Map<String, dynamic>) {
          jsonResponse = response.data;
        } else {
          throw Exception('Unexpected response data type');
        }

        PointHistoryResponse apiResponse = PointHistoryResponse.fromJson(
          jsonResponse,
        );

        if (apiResponse.isSuccess) {
          historyList.assignAll(apiResponse.data);
        } else {
          print("API RESPONCES DATA ${apiResponse.message}");
          // getFlutterToast('API Error: ${apiResponse.message}',Colors.red);
          // Get.snackbar('Error', apiResponse.message);
        }
      } else {
        getFlutterToast('HTTP Error: ${response.statusCode}', Colors.red);
        Get.snackbar('Error', 'Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      getFlutterToast('Exception: $e', Colors.red);
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoading(false);
    }
  }
}
