// class CoinHistoryModel {
//   String? pointId;
//   String? orderId;
//   String? customerId;
//   String? pointDescription;
//   String? pointType;
//   String? pointDate;
//   String? pointTotal;
//   String? pointTransactionNo;
//   String? pointStatus;
//   String? pointCDT;
//
//   CoinHistoryModel(
//       {this.pointId,
//         this.orderId,
//         this.customerId,
//         this.pointDescription,
//         this.pointType,
//         this.pointDate,
//         this.pointTotal,
//         this.pointTransactionNo,
//         this.pointStatus,
//         this.pointCDT});
//
//   CoinHistoryModel.fromJson(Map<String, dynamic> json) {
//     pointId = json['PointId'];
//     orderId = json['OrderId'];
//     customerId = json['CustomerId'];
//     pointDescription = json['PointDescription'];
//     pointType = json['PointType'];
//     pointDate = json['PointDate'];
//     pointTotal = json['PointTotal'];
//     pointTransactionNo = json['PointTransactionNo'];
//     pointStatus = json['PointStatus'];
//     pointCDT = json['PointCDT'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['PointId'] = this.pointId;
//     data['OrderId'] = this.orderId;
//     data['CustomerId'] = this.customerId;
//     data['PointDescription'] = this.pointDescription;
//     data['PointType'] = this.pointType;
//     data['PointDate'] = this.pointDate;
//     data['PointTotal'] = this.pointTotal;
//     data['PointTransactionNo'] = this.pointTransactionNo;
//     data['PointStatus'] = this.pointStatus;
//     data['PointCDT'] = this.pointCDT;
//     return data;
//   }
// }
class CoinHistoryModel {
  String? pointId;
  String? orderId;
  String? customerId;
  String? pointDescription;
  String? pointType;
  String? pointDate;
  String? pointTotal;
  String? pointTransactionNo;
  String? pointStatus;
  String? pointCDT;
  String? value;

  CoinHistoryModel({
    this.pointId,
    this.orderId,
    this.customerId,
    this.pointDescription,
    this.pointType,
    this.pointDate,
    this.pointTotal,
    this.pointTransactionNo,
    this.pointStatus,
    this.pointCDT,
    this.value,
  });

  CoinHistoryModel.fromJson(Map<String, dynamic> json) {
    pointId = json['PointId'] ?? json['RedeemId'];
    orderId = json['OrderId'];
    customerId = json['CustomerId'];
    pointDescription = json['PointDescription'] ?? json['Description'];
    pointType = json['PointType'] ?? "Redeem";
    pointDate = json['PointDate'] ?? json['RedeemCDT'];
    pointTotal = json['PointTotal'] ?? json['RedeemPoints'];
    pointTransactionNo = json['PointTransactionNo'];
    pointStatus = json['PointStatus'] ?? json['RedeemStatus'];
    pointCDT = json['PointCDT'] ?? json['RedeemCDT'];
    value = json['Value']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PointId'] = this.pointId;
    data['OrderId'] = this.orderId;
    data['CustomerId'] = this.customerId;
    data['PointDescription'] = this.pointDescription;
    data['PointType'] = this.pointType;
    data['PointDate'] = this.pointDate;
    data['PointTotal'] = this.pointTotal;
    data['PointTransactionNo'] = this.pointTransactionNo;
    data['PointStatus'] = this.pointStatus;
    data['PointCDT'] = this.pointCDT;
    data['Value'] = this.value;
    return data;
  }
}

// Response model for the API
class PointHistoryResponse {
  bool isSuccess;
  String message;
  List<CoinHistoryModel> data;

  PointHistoryResponse({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory PointHistoryResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['Data'] as List;
    List<CoinHistoryModel> historyList = dataList
        .map((item) => CoinHistoryModel.fromJson(item))
        .toList();

    return PointHistoryResponse(
      isSuccess: json['IsSuccess'] ?? false,
      message: json['Message'] ?? '',
      data: historyList,
    );
  }
}
