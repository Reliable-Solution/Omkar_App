import 'dart:convert';
import 'dart:developer' as developer;

import '../utils/sharedPrefs.dart';

final helper = SharedHelper();

class SettingModel {
  List<SettingInfo>? data;
  bool? isSuccess;
  String? message;
  // final helper = SharedHelper();

  SettingModel({this.data, this.isSuccess, this.message});

  SettingModel.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = <SettingInfo>[];
      json['Data'].forEach((v) {
        data!.add(new SettingInfo.fromJson(v));
      });
    }
    isSuccess = json['IsSuccess'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['Data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['IsSuccess'] = this.isSuccess;
    data['Message'] = this.message;
    return data;
  }
}

class SettingInfo {
  String? settingId;
  String? settingBaseURL;
  String? settingPhoneNumber;
  String? settingImage;
  String? settingCallingNumber;
  String? settingWhatsAppNumber;
  String? settingWhatsAppMessage;
  String? settingTermsConditionURL;
  String? settingPrivacyPolicyURL;
  String? settingFaqURL;
  String? settingHelpAndSupportURL;
  String? settingContactUsURL;
  String? settingsLowstock;
  String? settingRedeemPoints;
  String? settingEarnPointsPercentage;
  String? settingRedeemPointsMessage;
  String? settingCartRedeemPointsPercentage;
  String? settingAndroidAppLink;
  String? settingIosAppLink;
  String? settingReferSender;
  String? settingReferReciever;
  Map<String, String>? settingReferMessage;
  String? settingSignupBonus;
  String? settingMaintenanceMode;
  String? instantAPIToken;
  String? instantAPIURL;
  String? settingStatus;
  String? settingCDT;
  Map<String, String>? referTitle;
  String? referImage;
  String? minimumPoints;
  String? points;
  String? rupees;

  SettingInfo({
    this.settingId,
    this.settingBaseURL,
    this.settingPhoneNumber,
    this.settingImage,
    this.settingCallingNumber,
    this.settingWhatsAppNumber,
    this.settingWhatsAppMessage,
    this.settingTermsConditionURL,
    this.settingPrivacyPolicyURL,
    this.settingFaqURL,
    this.settingHelpAndSupportURL,
    this.settingContactUsURL,
    this.settingsLowstock,
    this.settingRedeemPoints,
    this.settingEarnPointsPercentage,
    this.settingRedeemPointsMessage,
    this.settingCartRedeemPointsPercentage,
    this.settingAndroidAppLink,
    this.settingIosAppLink,
    this.settingReferSender,
    this.settingReferReciever,
    this.settingReferMessage,
    this.settingSignupBonus,
    this.settingMaintenanceMode,
    this.instantAPIToken,
    this.instantAPIURL,
    this.settingStatus,
    this.settingCDT,
    this.referTitle,
    this.referImage,
    this.minimumPoints,
    this.points,
    this.rupees,
  });

  factory SettingInfo.fromJson(Map<String, dynamic> json) {
    // Helper for parsing multilingual strings to Map
    Map<String, String>? parseMultilingual(dynamic jsonValue) {
      if (jsonValue == null || jsonValue is! String || jsonValue.isEmpty)
        return null;
      try {
        final decoded = jsonDecode(jsonValue) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, value as String));
      } catch (e) {
        developer.log("Multilingual Parse Error: $e for value $jsonValue");
        return null;
      }
    }
    // SettingInfo.fromJson(Map<String, dynamic> json) {
    //   settingId = json['SettingId'];
    //   settingBaseURL = json['SettingBaseURL'];
    //   settingPhoneNumber = json['SettingPhoneNumber'];
    //   settingImage = json['SettingImage'];
    //   settingCallingNumber = json['SettingCallingNumber'];
    //   settingWhatsAppNumber = json['SettingWhatsAppNumber'];
    //   settingWhatsAppMessage = json['SettingWhatsAppMessage'];
    //   settingTermsConditionURL = json['SettingTermsConditionURL'];
    //   settingPrivacyPolicyURL = json['SettingPrivacyPolicyURL'];
    //   settingFaqURL = json['SettingFaqURL'];
    //   settingHelpAndSupportURL = json['SettingHelpAndSupportURL'];
    //   settingContactUsURL = json['SettingContactUsURL'];
    //   settingsLowstock = json['SettingsLowstock'];
    //   settingRedeemPoints = json['SettingRedeemPoints'];
    //   settingEarnPointsPercentage = json['SettingEarnPointsPercentage'];
    //   settingRedeemPointsMessage = json['SettingRedeemPointsMessage'];
    //   settingCartRedeemPointsPercentage =
    //       json['SettingCartRedeemPointsPercentage'];
    //   settingAndroidAppLink = json['SettingAndroidAppLink'];
    //   settingIosAppLink = json['SettingIosAppLink'];
    //   settingReferSender = json['SettingReferSender'];
    //   settingReferReciever = json['SettingReferReciever'];
    //   settingReferMessage = parseMultilingual(json['SettingReferMessage']);
    //   // json['SettingReferMessage'];
    //   settingSignupBonus = json['SettingSignupBonus'];
    //   settingMaintenanceMode = json['SettingMaintenanceMode'];
    //   instantAPIToken = json['Instant_API_token'];
    //   instantAPIURL = json['Instant_API_URL'];
    //   settingStatus = json['SettingStatus'];
    //   settingCDT = json['SettingCDT'];
    //   referTitle =parseMultilingual(json['ReferTitle']);
    //   // json['ReferTitle'];
    //   referImage = json['ReferImage'];
    // }

    return SettingInfo(
      settingId: json['SettingId'] as String?,
      settingBaseURL: json['SettingBaseURL'] as String?,
      settingPhoneNumber: json['SettingPhoneNumber'] as String?,
      settingImage: json['SettingImage'] as String?,
      settingCallingNumber: json['SettingCallingNumber'] as String?,
      settingWhatsAppNumber: json['SettingWhatsAppNumber'] as String?,
      settingWhatsAppMessage: json['SettingWhatsAppMessage'] as String?,
      settingTermsConditionURL: json['SettingTermsConditionURL'] as String?,
      settingPrivacyPolicyURL: json['SettingPrivacyPolicyURL'] as String?,
      settingFaqURL: json['SettingFaqURL'] as String?,
      settingHelpAndSupportURL: json['SettingHelpAndSupportURL'] as String?,
      settingContactUsURL: json['SettingContactUsURL'] as String?,
      settingsLowstock: json['SettingsLowstock'] as String?,
      settingRedeemPoints: json['SettingRedeemPoints'] as String?,
      settingEarnPointsPercentage:
          json['SettingEarnPointsPercentage'] as String?,
      settingRedeemPointsMessage: json['SettingRedeemPointsMessage'] as String?,
      settingCartRedeemPointsPercentage:
          json['SettingCartRedeemPointsPercentage'] as String?,
      settingAndroidAppLink: json['SettingAndroidAppLink'] as String?,
      settingIosAppLink: json['SettingIosAppLink'] as String?,
      settingReferSender: json['SettingReferSender'] as String?,
      settingReferReciever: json['SettingReferReciever'] as String?,
      // *** Parsing yahan add ki ***
      settingReferMessage: parseMultilingual(json['SettingReferMessage']),
      settingSignupBonus: json['SettingSignupBonus'] as String?,
      settingMaintenanceMode: json['SettingMaintenanceMode'] as String?,
      instantAPIToken: json['Instant_API_token'] as String?,
      instantAPIURL: json['Instant_API_URL'] as String?,
      settingStatus: json['SettingStatus'] as String?,
      settingCDT: json['SettingCDT'] as String?,
      referTitle: parseMultilingual(json['ReferTitle']),
      referImage: json['ReferImage'] as String?,
      minimumPoints: json['MinimumPoints']?.toString(),
      points: json['Points']?.toString(),
      rupees: json['Rupees']?.toString(),
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SettingId'] = this.settingId;
    data['SettingBaseURL'] = this.settingBaseURL;
    data['SettingPhoneNumber'] = this.settingPhoneNumber;
    data['SettingImage'] = this.settingImage;
    data['SettingCallingNumber'] = this.settingCallingNumber;
    data['SettingWhatsAppNumber'] = this.settingWhatsAppNumber;
    data['SettingWhatsAppMessage'] = this.settingWhatsAppMessage;
    data['SettingTermsConditionURL'] = this.settingTermsConditionURL;
    data['SettingPrivacyPolicyURL'] = this.settingPrivacyPolicyURL;
    data['SettingFaqURL'] = this.settingFaqURL;
    data['SettingHelpAndSupportURL'] = this.settingHelpAndSupportURL;
    data['SettingContactUsURL'] = this.settingContactUsURL;
    data['SettingsLowstock'] = this.settingsLowstock;
    data['SettingRedeemPoints'] = this.settingRedeemPoints;
    data['SettingEarnPointsPercentage'] = this.settingEarnPointsPercentage;
    data['SettingRedeemPointsMessage'] = this.settingRedeemPointsMessage;
    data['SettingCartRedeemPointsPercentage'] =
        this.settingCartRedeemPointsPercentage;
    data['SettingAndroidAppLink'] = this.settingAndroidAppLink;
    data['SettingIosAppLink'] = this.settingIosAppLink;
    data['SettingReferSender'] = this.settingReferSender;
    data['SettingReferReciever'] = this.settingReferReciever;
    data['SettingReferMessage'] = settingReferMessage != null
        ? jsonEncode(settingReferMessage)
        : null;
    // this.settingReferMessage;
    data['SettingSignupBonus'] = this.settingSignupBonus;
    data['SettingMaintenanceMode'] = this.settingMaintenanceMode;
    data['Instant_API_token'] = this.instantAPIToken;
    data['Instant_API_URL'] = this.instantAPIURL;
    data['SettingStatus'] = this.settingStatus;
    data['SettingCDT'] = this.settingCDT;
    data['ReferTitle'] = referTitle != null ? jsonEncode(referTitle) : null;
    // this.referTitle;
    data['ReferImage'] = this.referImage;
    data['MinimumPoints'] = this.minimumPoints;
    data['Points'] = this.points;
    data['Rupees'] = this.rupees;
    return data;
  }

  // Getters
  Future<String> get referMessageLocalized async {
    final language = await _getLanguage();
    return _getLocalizedValue(settingReferMessage, language);
  }

  Future<String> get referTitleLocalized async {
    final language = await _getLanguage();
    return _getLocalizedValue(referTitle, language);
  }

  Future<String> _getLanguage() async {
    final lang = await helper.getStoredString("languageNameFinal");
    return lang?.toLowerCase() ?? 'english';
  }

  String _getLocalizedValue(Map<String, String>? map, String language) {
    if (map == null) return '';
    if (language.contains('hindi') && map['hindi'] != null)
      return map['hindi']!;
    if (language.contains('gujarati') && map['gujarati'] != null)
      return map['gujarati']!;
    if (language.contains('marathi') && map['marathi'] != null)
      return map['marathi']!;
    return map['english'] ?? '';
  }
}
//
// // Getters
// Future<String> get referMessageLocalized async {
//   final language = await _getLanguage();
//   return _getLocalizedValue(settingReferMessage, language);
// }
//
// Future<String> get referTitleLocalized async {
//   final language = await _getLanguage();
//   return _getLocalizedValue(referTitle, language);
// }
//
// Future<String> _getLanguage() async {
//   final lang = await helper.getStoredString("languageNameFinal");
//   return lang?.toLowerCase() ?? 'english';
// }
//
// String _getLocalizedValue(Map<String, String>? map, String language) {
//   if (map == null) return '';
//   if (language.contains('hindi') && map['hindi'] != null) return map['hindi']!;
//   if (language.contains('gujarati') && map['gujarati'] != null) return map['gujarati']!;
//   if (language.contains('marathi') && map['marathi'] != null) return map['marathi']!;
//   return map['english'] ?? '';
// }