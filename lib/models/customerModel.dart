class CustomerModel {
  String? customerId;
  String? firmId;
  String? customerName;
  String? customerImage;
  String? customerEmailId;
  String? customerGender;
  String? customerFCMToken;
  String? customerPhoneNo;
  String? customerCode;
  String? customerReferCode;
  String? points;
  String? referUser;
  String? city;
  String? documentsImage;
  String? address;
  String? role;
  String? status;
  String? customerStatus;
  String? customerCDT;

  CustomerModel({
    this.customerId,
    this.firmId,
    this.customerName,
    this.customerImage,
    this.customerEmailId,
    this.customerGender,
    this.customerFCMToken,
    this.customerPhoneNo,
    this.customerCode,
    this.customerReferCode,
    this.points,
    this.referUser,
    this.city,
    this.documentsImage,
    this.address,
    this.role,
    this.status,
    this.customerStatus,
    this.customerCDT,
  });

  CustomerModel.fromJson(Map<String, dynamic> json) {
    customerId = json['CustomerId']?.toString();
    firmId = json['FirmId']?.toString();
    customerName = json['CustomerName']?.toString();
    customerImage = json['CustomerImage']?.toString();
    customerEmailId = json['CustomerEmailId']?.toString();
    customerGender = json['CustomerGender']?.toString();
    customerFCMToken = json['CustomerFCMToken']?.toString();
    customerPhoneNo = json['CustomerPhoneNo']?.toString();
    customerCode = json['CustomerCode']?.toString();
    customerReferCode = json['CustomerReferCode']?.toString();
    points = json['Points']?.toString();
    referUser = json['ReferUser']?.toString();
    city = json['City']?.toString();
    documentsImage = json['DocumentsImage']?.toString();
    address = json['Address']?.toString();
    role = json['Role']?.toString();
    status = json['Status']?.toString();
    customerStatus = json['CustomerStatus']?.toString();
    customerCDT = json['CustomerCDT']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CustomerId'] = customerId;
    data['FirmId'] = firmId;
    data['CustomerName'] = customerName;
    data['CustomerImage'] = customerImage;
    data['CustomerEmailId'] = customerEmailId;
    data['CustomerGender'] = customerGender;
    data['CustomerFCMToken'] = customerFCMToken;
    data['CustomerPhoneNo'] = customerPhoneNo;
    data['CustomerCode'] = customerCode;
    data['CustomerReferCode'] = customerReferCode;
    data['Points'] = points;
    data['ReferUser'] = referUser;
    data['City'] = city;
    data['DocumentsImage'] = documentsImage;
    data['Address'] = address;
    data['Role'] = role;
    data['Status'] = status;
    data['CustomerStatus'] = customerStatus;
    data['CustomerCDT'] = customerCDT;
    return data;
  }
}
