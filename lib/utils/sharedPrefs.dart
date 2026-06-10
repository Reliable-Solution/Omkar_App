import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/customerModel.dart';

class SharedHelper {
  static String customerModelKey = "customerModelKey";
  static String deleteAccountKey = "deleteAccountKey";
  static const String _carpenterPendingKey = 'carpenterPendingKey';
  static const String _carpenterPendingPhoneKey = 'carpenterPendingPhoneKey';
  static const String _firmIdKey = 'firmIdKey';

  Future<void> setCustomer(
    CustomerModel customerModel,
    String fromScreen,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Merge logic: If we already have data, don't overwrite mandatory fields with nulls from profile update
      if (fromScreen == "Edit Profile Controller" ||
          fromScreen == "Auth controller login") {
        CustomerModel? existing = await getCustomer();
        if (existing != null) {
          customerModel.customerPhoneNo ??= existing.customerPhoneNo;
          customerModel.customerFCMToken ??= existing.customerFCMToken;
          customerModel.customerId ??= existing.customerId;
          if (customerModel.points == null || customerModel.points!.isEmpty) {
            customerModel.points = existing.points;
          }
        }
      }

      String customerJson = jsonEncode(customerModel.toJson());
      debugPrint(
        " [SharedHelper] Storing Customer from $fromScreen: $customerJson",
      );

      bool success = await prefs.setString(customerModelKey, customerJson);
      if (!success) {
        debugPrint(" [SharedHelper] Failed to write to SharedPreferences!");
      }
    } catch (e) {
      debugPrint(" [SharedHelper] Error in setCustomer: $e");
    }
  }

  Future<CustomerModel?> getCustomer() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? customerJson = prefs.getString(customerModelKey);

      if (customerJson != null &&
          customerJson.isNotEmpty &&
          customerJson != "null") {
        debugPrint("📖 [SharedHelper] Retrieved Customer JSON: $customerJson");
        Map<String, dynamic> customerMap = jsonDecode(customerJson);
        if (customerMap.isEmpty) return null;

        CustomerModel customerModel = CustomerModel.fromJson(customerMap);

        // Safety check: if mandatory fields like customerId are missing, it's a bad record
        if (customerModel.customerId == null ||
            customerModel.customerId!.isEmpty) {
          debugPrint(
            "⚠️ [SharedHelper] Retrieved Customer is missing CustomerId!",
          );
        }

        return customerModel;
      }
    } catch (e) {
      debugPrint(" [SharedHelper] Error in getCustomer: $e");
    }
    return null;
  }

  Future<void> storeString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getStoredString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> storeBool({required String key, required bool value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool?> getStoredBool({required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<void> deleteCustomer() async {
    try {
      debugPrint(" [SharedHelper] Deleting Customer data");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(customerModelKey);
    } catch (e) {
      debugPrint(" [SharedHelper] Error in deleteCustomer: $e");
    }
  }

  /// Mark carpenter pending status. If [isPending] is true, an optional [phone]
  /// can be stored to help identify the pending account.
  Future<void> setCarpenterPendingStatus(bool isPending, [String? phone]) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_carpenterPendingKey, isPending);
      if (phone != null) await prefs.setString(_carpenterPendingPhoneKey, phone);
    } catch (e) {
      debugPrint(' [SharedHelper] Error in setCarpenterPendingStatus: $e');
    }
  }

  /// Returns true if carpenter pending flag is set, false otherwise.
  Future<bool> isCarpenterPending() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_carpenterPendingKey) ?? false;
    } catch (e) {
      debugPrint(' [SharedHelper] Error in isCarpenterPending: $e');
      return false;
    }
  }

  /// Returns stored phone for pending carpenter, if any.
  Future<String?> getCarpenterPendingPhone() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_carpenterPendingPhoneKey);
    } catch (e) {
      debugPrint(' [SharedHelper] Error in getCarpenterPendingPhone: $e');
      return null;
    }
  }

  /// Clears carpenter pending flag and any associated phone.
  Future<void> clearCarpenterPendingStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_carpenterPendingKey);
      await prefs.remove(_carpenterPendingPhoneKey);
    } catch (e) {
      debugPrint(' [SharedHelper] Error in clearCarpenterPendingStatus: $e');
    }
  }
}
