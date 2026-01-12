import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:omkar_app/controller/homeController.dart';

import '../constant/api_endpoints.dart';
import '../models/MonthlyUser.dart';
import '../models/prizeModel.dart';
import '../utils/services/api_services.dart';

class LeaderboardController extends GetxController {
  HomeController homeController = Get.find();
  final monthlyUsers = <MonthlyUser>[].obs;
  final prizes = <Prize>[].obs;
  final isLoading = true.obs;
  // final selectedMonth = '09'.obs; // Default month
  // final selectedYear = 2025.obs; //
  final selectedMonth = DateFormat(
    'MM',
  ).format(DateTime.now()).obs; // Current month in MM format
  final selectedYear = DateTime.now().year.obs; // Current year

  Future<void> fetchData() async {
    isLoading(true);

    try {
      final Map<String, dynamic> body = {
        'CustomerId': homeController.customerModel!.value.customerId,
        'Month': selectedMonth.value,
        'Year': selectedYear.value,
      };

      // Call APIs
      final prizeRes = await ApiService.post(endpoint: getPrizeData);
      var monthlyRes = await ApiService.post(
        endpoint: getMonthlyData,
        body: body,
      );

      if (prizeRes.data['IsSuccess'] == true) {
        prizes.assignAll(
          (prizeRes.data['Data'] as List).map((e) => Prize.fromJson(e)),
        );
      }
      print("Prize data ${prizeRes.data}");

      print("Monthly data ${monthlyRes.data}");
      print("Type of monthlyRes: ${monthlyRes.runtimeType}");
      print("Type of monthlyRes.data: ${monthlyRes.data.runtimeType}");
      final responseBody = jsonDecode(monthlyRes.data);

      if (responseBody is Map<String, dynamic> &&
          responseBody['IsSuccess'] == true) {
        final data = responseBody['Data'];
        print("Data is a List ${(data as List).length}");
        if (data is List) {
          monthlyUsers.assignAll(
            data.map((e) => MonthlyUser.fromJson(e)).toList(),
          );
        } else {
          print("Data is not a List – actual type: ${data.runtimeType}");
          monthlyUsers.clear(); // Clear list if data is invalid
        }
      } else {
        monthlyUsers.clear(); // Clear list if response is invalid
        Fluttertoast.showToast(
          msg: "No leaderboard data available",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        // }
        print("Invalid response format – ${monthlyRes.data}");
      }
    } catch (e) {
      print("Error fetching data: $e");
      monthlyUsers.clear();
      Fluttertoast.showToast(
        msg: "Error fetching leaderboard data: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
  // isLoading(false);

  void updateDate(int year, String month) {
    selectedYear.value = year;
    selectedMonth.value = month;
    fetchData(); // Fetch data with the new month and year
  }

  Prize? getPrizeForRank(int rank) {
    return prizes.firstWhereOrNull((p) => p.prizePosition == rank);
  }
}
