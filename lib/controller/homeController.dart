//flutter
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omkar_app/constant/api_endpoints.dart';
import 'package:omkar_app/controller/editController.dart';
import 'package:omkar_app/controller/networkController.dart';
import 'package:omkar_app/models/educationModel.dart';
import 'package:omkar_app/models/productModel.dart';
import 'package:omkar_app/models/subCategoryModel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../constant/app_constant.dart';
import '../constant/colorConst.dart';
import '../models/brandModel.dart';
import '../models/categoryModel.dart';
import '../models/customerModel.dart';
import '../models/dieaseModel.dart';
import '../models/offerModel.dart';
import '../models/searchModel.dart';
import '../models/tagModel.dart';
import '../utils/services/api_services.dart';
import '../utils/sharedPrefs.dart';
import '../utils/string_res.dart';
import '../widget/productDetailView.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  NetworkController networkController = Get.put(NetworkController());
  EditProfileController editProfileController =
      Get.find<EditProfileController>();
  SharedHelper helper = SharedHelper();
  var isDashBoardLoading = false.obs;
  var isSearchLoading = false.obs;
  var search = TextEditingController();
  var deliveryPincode = TextEditingController();
  var products = <dynamic>[].obs;
  var fdeliveryPincode = FocusNode();
  var userName = "";
  TabController? myTabController;
  Rx<CustomerModel>? customerModel = CustomerModel().obs;
  var activeIndex = 0.obs;
  var educationIndex = 0.obs;
  var selectedFilterIndex = 0.obs;
  var sortValue = 1.obs;
  List<CategoryModel> categoryList = [];
  List<SubCategory> subCategoryList = [];
  List<ProductModel> productList = [];
  List<OfferModel> offerList = [];
  List<BrandModel> brandList = [];
  List<ProductModel> searchList = [];
  List<Blogs> blogList = [];
  List<EducationData> educationList = [];
  List<Blogs> searchBlogs = [];
  List<TagModel> tagProductList = [];
  List<Disease> diseaseProductList = [];

  PageController filterPage = PageController();
  RxBool isCategory = false.obs;
  TextEditingController txtFullname = TextEditingController();
  TextEditingController txtMobileno = TextEditingController();
  TextEditingController txtPincode = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtLandmark = TextEditingController();
  TextEditingController txtType = TextEditingController();
  var searchController = TextEditingController();
  CustomerModel? m1 = CustomerModel();
  var searchQuery = ''.obs;
  var speechToText = stt.SpeechToText();

  RxInt indexNew = 0.obs;

  RxBool isBlogSearching = false.obs;
  var currentLabelIndex = 0.obs; // Observable for current label index
  List<String> get searchLabels => [
    StringRes.searchProduct,
    StringRes.searchBrand,
    StringRes.searchInsecticide,
    StringRes.searchSuperKiller,
    StringRes.searchCoragen,
    // 'Search Product',
    // 'Search Brand',
    // 'Search Insecticide',
    // 'Search SuperKiller',
    // 'Search Coragen',
  ];
  Timer? _timer;

  final List<ProductModel> _allProducts = [];

  List<ProductModel> get allProducts => _allProducts;

  TextEditingController searchBlogController = TextEditingController();

  Map<String, dynamic>? lastJson;

  // Method to refresh dashboard data
  Future<void> refreshDashboard() async {
    try {
      isDashBoardLoading.value = true;
      // Clear existing data
      categoryList.clear();
      offerList.clear();
      educationList.clear();

      // Re-fetch the dashboard data
      if (m1?.customerId != null) {
        await getDashboardData(m1?.customerId);
        await editProfileController.GetProfile(
          customerId: m1?.customerId.toString() ?? "",
        );
        await getPrefs(); // Reload local model to reflect profile changes
      }

      // await getDashboardData(m1?.customerId);
    } catch (e) {
      print('Error refreshing dashboard: $e');
    } finally {
      isDashBoardLoading.value = false;
    }
  }

  void collectAllProducts(Map<String, dynamic> json) {
    _allProducts.clear();

    // 1. Direct Product list
    final productList = json['Data']?[4]['Product'] as List<dynamic>? ?? [];
    _allProducts.addAll(productList.map((e) => ProductModel.fromJson(e)));

    // 2. Tag-wise products
    final tagList = json['Data']?[3]['Tag'] as List<dynamic>? ?? [];
    for (var tag in tagList) {
      final products = tag['Products'] as List<dynamic>? ?? [];
      _allProducts.addAll(products.map((e) => ProductModel.fromJson(e)));
    }

    // Remove duplicates (by ProductId)
    final ids = <String>{};
    _allProducts.retainWhere((p) => ids.add(p.productId!));
  }

  @override
  void onClose() {
    _timer?.cancel(); // Clean up timer
    super.onClose();
  }

  // Your existing search methods
  void clearSearch() {
    searchList.clear();
    searchController.clear();
    blogList.clear();
  }

  @override
  void onInit() async {
    myTabController = TabController(vsync: this, length: filters.length);
    m1 = await helper.getCustomer();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      currentLabelIndex.value =
          (currentLabelIndex.value + 1) % searchLabels.length;
    });
    // getDashboardData(m1!.customerId);
    getPrefs();

    // fetchCategoryData();
    super.onInit();
  }

  @override
  void dispose() {
    myTabController!.dispose();
    filterPage.dispose();
    super.dispose();
  }

  HomeController() {
    debugPrint("HomeController instance created with hash: $hashCode");
  }

  Future<void> getPrefs() async {
    CustomerModel? customer = await helper.getCustomer();
    if (customer != null) {
      customerModel!.value = customer;
      m1 = customer; // Update m1 as well
      debugPrint(" Name: ${customer.customerName}");
      debugPrint("=========> Name and Points: ${customer.points}");
      debugPrint("Controller hash in HomeController: $hashCode");
      debugPrint("Updated Name: ${customer.customerName}");
      update(); // agar tu GetBuilder bhi use kar raha hai
    }
  }

  // Added Method to clear data on Logout
  void clearData() {
    customerModel?.value = CustomerModel();
    m1 = CustomerModel();
    categoryList.clear();
    offerList.clear();
    brandList.clear();
    productList.clear();
    searchList.clear();
    blogList.clear();
    educationList.clear();
    update();
    debugPrint("HomeController Data Cleared");
  }

  List<String> filters = [
    'Category',
    'Gender',
    'Fabric',
    'Color',
    'Price',
    'Discount',
    'Rating',
    'Size',
    'Combo',
    'Material',
    'Bottom Length',
    'Bottom Style',
    'Bottomwear Fabric',
    'Ornmentation',
  ];

  //pricelist
  final price = [99, 199, 299, 399, 499];

  /// Get dashboard all data
  Future<void> getDashboardData(String? customerId) async {
    // Ensure lists are empty before populating them
    categoryList.clear();
    offerList.clear();
    brandList.clear();
    productList.clear();

    isDashBoardLoading.value = true;
    update(); // Trigger UI update to show Shimmer

    String? languageName = await helper.getStoredString("languageNameFinal");
    debugPrint("=========> Language Name HomeScreen $languageName");
    try {
      final Map<String, dynamic> body = {
        'CustomerId': customerId,
        'FirmId': firmId,
        "LanguageName": languageName,
      };

      // Make the API call
      var response = await ApiService.post(
        endpoint: getDashboardDataTestByUser,
        body: body,
      );

      if (response.data['IsSuccess'] == true) {
        getEducationData();
        debugPrint("API Response: ${response.data}");
        log("API Response: ${response.data}");

        var data = response.data['Data'] as List<dynamic>;

        debugPrint("========> Data Type ${data.runtimeType}");
        debugPrint("========> Data Length: ${data.length}");

        // Parse Offer from data[0]
        if (data.isNotEmpty && data[0]['Offer'] != null) {
          debugPrint(" Found Offers in data[0]");
          offerList = (data[0]['Offer'] as List? ?? [])
              .map((offerJson) => OfferModel.fromJson(offerJson))
              .toList();
          debugPrint("Offer Count: ${offerList.length}");
        }

        // Parse Products from data[1]
        if (data.length > 1 && data[1]['Product'] != null) {
          debugPrint(" Found Products in data[1]");
          productList = (data[1]['Product'] as List? ?? [])
              .map((productJson) => ProductModel.fromJson(productJson))
              .toList();
          debugPrint(" Product Count: ${productList.length}");
        }

        isDashBoardLoading.value = false;
        update();
      } else {
        isDashBoardLoading.value = false;
        throw Exception("Error from API: ${response.data['Message']}");
      }
    } catch (e) {
      debugPrint("Error in getDashboardData: $e");
      throw Exception("Failed to get dashboard data: $e");
    }
  }

  Future<void> getProductData(String? productId) async {
    productList.clear();

    try {
      final Map<String, dynamic> body = {
        "ProductId": productId,
        // 'CustomerId': customerId,
        // 'FirmId': firmId
      };

      // Make the API call
      var response = await ApiService.post(
        endpoint: getProductbyID,
        body: body,
      );

      if (response.data['IsSuccess'] == true) {
        var data = response.data['Data'];
        // if (data[0]['Product'] != null) {
        productList = (data as List)
            .map((productJson) => ProductModel.fromJson(productJson))
            .toList();
        // }
        final product = productList.first;
        Get.to(
          () => ProductDetailScreen(products: product, fromDeepLink: true),
        );
        // isDashBoardLoading.value = false;
        update();
      } else {
        throw Exception("Error from API: ${response.data['Message']}");
      }
    } catch (e) {
      debugPrint("Error in getDashboardData: $e");
      throw Exception("Failed to get dashboard data: $e");
    }
  }

  getEducationData() async {
    // isSearchLoading.value= true;
    // final data = await helper.getCustomer();
    // print("customer data in education ${data?.toJson()}");
    // update();
    // educationList.clear();
    // try {
    //   final Map<String, dynamic> body = {
    //     // "CustomerId": customerModel!.value.customerId,
    //     // "ProductName": productName,
    //     // 'FirmId':firmId
    //   };

    //   var response = await ApiService.post(
    //     endpoint: getEducationalData,
    //     body: body,
    //   );
    //   log("Responces education data ${response.data}");
    //   if (response.data['IsSuccess'] == true) {
    //     educationList = (response.data['Data'] as List)
    //         .map((educationJson) => EducationData.fromJson(educationJson))
    //         .toList();
    //     debugPrint("education data ${educationList.length}");
    //     update();
    //   } else {
    //     throw Exception("Error: ${response.data['Message']}");
    //   }
    // } catch (e) {
    //   debugPrint("Error in getDashboard Data: $e");
    //   throw Exception("Failed to getDashboard Data");
    // } finally {RRRR
    //   debugPrint("isSearch debugPrint 3 ${isSearchLoading.value}");
    //   // isSearchLoading.value= false;

    //   update();
    // }
  }

  Future<void> searchBlogsApi(String query) async {
    if (query.isEmpty) {
      searchBlogs.clear();
      return;
    }

    isBlogSearching.value = true; // 🔥 Start loader
    try {
      final body = {"search": query};

      final response = await ApiService.post(
        endpoint: searchByBlog,
        body: body,
      );

      if (response.data['IsSuccess'] == true) {
        debugPrint("======= Search Data ${response.data['Data']['blogs']}");
        log("======= Search Data ${response.data['Data']['blogs']}");
        final data = response.data['Data']['blogs'] as List;
        searchBlogs.assignAll(data.map((e) => Blogs.fromJson(e)).toList());
      } else {
        searchBlogs.clear();
      }
    } catch (e) {
      debugPrint("Search blogs error: $e");
      searchBlogs.clear();
    } finally {
      isBlogSearching.value = false; //  Stop loader
    }
  }

  void onSearchChanged(String query) {
    debugPrint(" query $query");
    if (query.isEmpty) {
      searchList.clear();
      blogList.clear();
      // isSearchLoading.value = true;
      update();
    }
    searchQuery.value = query;
    getSearchData(query);
  }

  Future<void> startVoiceSearch(BuildContext context) async {
    bool available = await speechToText.initialize();
    if (available) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Listening...",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: COLOR.appBaseColor,
                  child: Icon(Icons.mic, size: 50, color: Colors.white),
                ),
                SizedBox(height: 15),
                Text(
                  "Speak now...",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
      speechToText.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            getSearchData(result.recognizedWords, isSpeech: true);
            searchController.text = result.recognizedWords;
            print("=======================------");
          }
        },
      );
    }
  }

  getSearchData(String productName, {bool isSpeech = false}) async {
    if (isSpeech && !isSearchLoading.value) {
      Navigator.of(Get.context!).pop();
    }
    isSearchLoading.value = true;
    update();
    debugPrint("isSearch debugPrint 1: ${isSearchLoading.value}");

    await Future.delayed(Duration(seconds: 2)); // Increase delay for testing

    // await Future.delayed(Duration(milliseconds: 500)); // Minimum loader time
    if (productName.isEmpty) {
      products.clear();
      isSearchLoading.value = false;
      update();
      return;
    }
    try {
      String? languageName = await helper.getStoredString("languageNameFinal");
      debugPrint("=========> Language Name HomeScreen $languageName");
      final Map<String, dynamic> body = {
        "CustomerId": customerModel!.value.customerId,
        "ProductName": productName,
        'FirmId': firmId,
        "LanguageName": languageName,
      };
      debugPrint("isSearch debugPrint 2 ${isSearchLoading.value}");

      var response = await ApiService.post(endpoint: searchByUser, body: body);
      if (response.data['IsSuccess'] == true) {
        searchList = (response.data['Data'] as List)
            .map((searchJson) => ProductModel.fromJson(searchJson))
            .toList();
        debugPrint("Blog data ${response.data}");
        blogList = (response.data['blog'] as List)
            .map((blogJson) => Blogs.fromJson(blogJson))
            .toList();

        debugPrint("Search data ${searchList.length}");
        debugPrint("======> Blog data ${blogList.length}");
        debugPrint("======> Blog data ${blogList.length}");
        isSearchLoading.value = false;
        update();
      } else {
        throw Exception("Error: ${response.data['Message']}");
      }
    } catch (e) {
      debugPrint("Error in getDashboard Data: $e");
      throw Exception("Failed to getDashboard Data");
      // debugPrint("Error in Fetch Search Data: $e");
      // throw Exception("Failed to fetch Search data");
    } finally {
      debugPrint("isSearch debugPrint 3 ${isSearchLoading.value}");

      // update();
      isSearchLoading.value = false;
      // debugPrint("isSearch debugPrint 4 ${isSearchLoading.value}");

      update();

      debugPrint("isSearch debugPrint 4 ${isSearchLoading.value}");

      // isLoading(false);
    }
  }
}
