import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omkar_app/controller/productDetailController.dart';
import 'package:omkar_app/models/productModel.dart';
import 'package:omkar_app/utils/services/api_services.dart';
import 'package:omkar_app/widget/textWidget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../Theme/nativeTheme.dart';
import '../constant/app_constant.dart';
import '../constant/colorConst.dart';
import '../controller/cartController.dart';
import '../controller/homeController.dart';
import '../controller/shareProductsController.dart';
import '../utils/string_res.dart';
import '../view/AddtoCard/cartScreen.dart';
import '../view/wishlist/wishlist_screen.dart';
import 'alignWidget.dart';
import 'appBarWidget.dart';
import 'buttonWidget.dart';
import 'dividerWidgets.dart';
import 'iconButtonWidget.dart';

class ProductDetailScreen extends StatefulWidget {
  ProductModel? products;
  final bool? isExpanded;
  final bool? fromDeepLink;

  ProductDetailScreen({
    super.key,
    this.products,
    this.isExpanded,
    this.fromDeepLink,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductDetailsController productDetailsController = Get.find();
  ShareProductController shareProductController = Get.find();
  HomeController homeController = Get.find();
  int _currentIndex = 0;
  int _selectedIndex = 0;
  final int _selectedColorIndex = 0;
  List<PackInfo> productListOFPackInfo = [];
  PackInfo? packInfoOfSelected;

  final CartController cartController = Get.put(CartController());

  bool isNewPack = false;

  bool isShareLoad = false;

  double calculateDiscount(double mrp, double srp) {
    // if (mrp <= 0 || srp > mrp) {
    //   throw Exception("Invalid MRP or SRP values");
    // }
    double discount = ((mrp - srp) / mrp) * 100;
    return discount;
  }

  void productRemove(String productDetailId) {
    // Update the specific packInfo based on ID (handles multiple variants)
    for (var pack in productListOFPackInfo) {
      if (pack.productdetailId == productDetailId) {
        pack.isCart = false;
      }
    }
    if (isNewPack && packInfoOfSelected?.productdetailId == productDetailId) {
      packInfoOfSelected!.isCart = false;
    }
    setState(() {}); // Force rebuild
    productDetailsController.update();
  }

  void changeSearchLoader(bool value) {
    setState(() => isShareLoad = value);
  }

  bool isProductInCart(String productDetailId) {
    return cartController.cartList.any(
      (item) => item.productdetailId == productDetailId,
    );
  }

  @override
  void initState() {
    productListOFPackInfo = widget.products!.packInfo!
        .where((e) => e.productIdReference == widget.products?.productId)
        .toList();

    if (widget.fromDeepLink!) {
      final productId = widget.products?.productId;
      if (productId != null) {
        final homeController = Get.find<HomeController>();
        homeController.getProductData(productId).then((_) {
          if (homeController.productList.isNotEmpty) {
            setState(() {
              widget.products = homeController.productList.first;
            });
          }
        });
      } else {
        throw Exception("Product ID missing in deep-link");
      }
    }

    // Skip initialization of Qty from packInfo since packInfo is empty
    // productDetailsController.Qty = int.parse(productListOFPackInfo[0].cartqty!);
    // productDetailsController.productQty = int.parse(
    //   "${productListOFPackInfo[0].productdetailQty}",
    // );

    if (widget.products!.qty!.isNotEmpty) {
      _selectedIndex = 0;
    }
    getProductInfo(
      qtySize: widget.products!.qty!.isNotEmpty ? widget.products!.qty![0] : "",
    );
    _currentIndex = 0;

    super.initState();
  }

  getProductInfo({required String qtySize}) {
    for (int i = 0; i < productListOFPackInfo.length; i++) {
      if (productListOFPackInfo[i].productQty == qtySize) {
        packInfoOfSelected = productListOFPackInfo[i];
        isNewPack = true;
      }
    }
    setState(() {
      _currentIndex = 0;
    });
  }

  // New method to sync local isCart with server cartList
  Future<void> _syncIsCartWithServer() async {
    await cartController.getCartDetails(
      cartController.customerModel!.value.customerId!,
    );
    for (var pack in productListOFPackInfo) {
      pack.isCart = isProductInCart(pack.productdetailId!);
    }
    if (isNewPack) {
      packInfoOfSelected!.isCart = isProductInCart(
        packInfoOfSelected!.productdetailId!,
      );
    }
    setState(() {});
    productDetailsController.update();
    cartController.update();
  }

  @override
  Widget build(BuildContext context) {
    for (var element in productListOFPackInfo) {
      print("=======>>>> widget.products ${element.toJson()}");
    }
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: MyCustomAppBar(
          actionPadding: 10,
          height: 90,
          text: widget.products?.productName,
          appbarPadding: 0,
          action: [
            Stack(
              children: [
                // IconButtonWidget(
                //   voidCallback: () async {
                //     cartController.redeemPointsController.clear();
                //     cartController.getCartDetails(
                //       cartController.customerModel!.value.customerId!,
                //     );
                //     cartController.getCartTotal(
                //       cartController.customerModel!.value.customerId!,
                //     );
                //     await Get.to(() => CartScreen(removeCart: productRemove));
                //     // Refresh on return from cart
                //     await _syncIsCartWithServer();
                //   },
                //   icons: Icons.shopping_cart_outlined,
                //   color: COLOR.background,
                // ),
                // Positioned(
                //   right: 0,
                //   top: -05,
                //   child: GetBuilder<CartController>(
                //     builder: (cartController) {
                //       int cartCount = cartController.cartList.length;
                //       return cartCount > 0
                //           ? Container(
                //               padding: EdgeInsets.all(5),
                //               alignment: Alignment.centerLeft,
                //               decoration: BoxDecoration(
                //                 color: Colors.red,
                //                 shape: BoxShape.circle,
                //               ),
                //               child: Text(
                //                 cartCount.toString(),
                //                 style: TextStyle(
                //                   color: Colors.white,
                //                   fontSize: 12,
                //                   fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //             )
                //           : SizedBox();
                //     },
                //   ),
                // ),
              ],
            ),
          ],
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: COLOR.background,
              size: 20,
            ),
          ),
        ),
        backgroundColor: COLOR.greyLight,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: CarouselSlider.builder(
                  itemCount: widget.products?.productImage != null ? 1 : 0,
                  // itemCount: isNewPack
                  //     ? packInfoOfSelected!.productdetailImages!.length
                  //     : productListOFPackInfo[0].productdetailImages!.length,
                  itemBuilder: (context, index, realIndex) {
                    return GestureDetector(
                      onTap: () {
                        // print("=======>>>> widget.products ${widget.products!.packInfo![0].productdetailImages}");
                        // print("=======>>>> widget.products ${widget.products!.packInfo![0].productdetailImages}");
                        // print("=======>>>> widget.products $isNewPack ${packInfoOfSelected!.productdetailImages}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductImageScreen(
                              imageUrls: [widget.products!.productImage!],
                              // imageUrls: isNewPack
                              //     ? packInfoOfSelected!.productdetailImages!
                              //     : productListOFPackInfo[0]
                              //           .productdetailImages!,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 2,
                        scaleEnabled: true,
                        constrained: true,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: COLOR.background,
                              image: DecorationImage(
                                image: NetworkImage(
                                  '$IMAGE_URL${widget.products!.productImage!}',
                                  // isNewPack
                                  //     ? '$IMAGE_URL${packInfoOfSelected!.productdetailImages![_currentIndex]}'
                                  //     : '$IMAGE_URL${productListOFPackInfo[0].productdetailImages![0]}',
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),
                            height:
                                (MediaQuery.of(context).size.height * 25) / 100,
                          ),
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * 0.38,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
              ),
              Container(
                color: COLOR.background,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Column(
                  children: <Widget>[
                    AlignWidget(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 5, top: 10),
                            alignment: Alignment.centerLeft,
                            child: TextWiget(
                              title: '${widget.products!.productName}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: COLOR.grey,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                            child: TextWiget(
                              title: StringRes.productImages,
                              style: Themes.dark.textTheme.displayMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: COLOR.black,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ),
                          SizedBox(
                            height: 70,
                            child: ListView.builder(
                              itemCount: 1,
                              // itemCount: isNewPack
                              //     ? packInfoOfSelected!
                              //           .productdetailImages!
                              //           .length
                              //     : productListOFPackInfo[0]
                              //           .productdetailImages!
                              //           .length,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  padding: EdgeInsets.all(15),
                                  height: 50,
                                  width: 50,
                                  margin: EdgeInsets.all(02),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(05),
                                    border: Border.all(
                                      color: _currentIndex == index
                                          ? COLOR.appBaseColor
                                          : COLOR.appBaseColor.withOpacity(0.5),
                                      width: _currentIndex == index ? 2.0 : 1.0,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        '$IMAGE_URL${widget.products!.productImage!}',
                                        // isNewPack
                                        //     ? '$IMAGE_URL${packInfoOfSelected!.productdetailImages![index]}'
                                        //     : '$IMAGE_URL${productListOFPackInfo[0].productdetailImages![index]}',
                                      ),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              // Container(
                              //   padding: EdgeInsets.only(bottom: 5, top: 10),
                              //   alignment: Alignment.centerLeft,
                              //   child: TextWiget(
                              //     title: '${widget.products!.productName}',
                              //     style: GoogleFonts.poppins(
                              //       fontSize: 14,
                              //       fontWeight: FontWeight.w500,
                              //       color: COLOR.grey,
                              //     ),
                              //   ),
                              // ),
                              Builder(
                                builder: (context) {
                                  // PackInfo-based pricing commented out since PackInfo is empty
                                  // final srp =
                                  //     num.tryParse(
                                  //       widget
                                  //               .products!
                                  //               .packInfo![0]
                                  //               .productdetailSrp ??
                                  //           "0",
                                  //     ) ??
                                  //     0;
                                  // final mrp =
                                  //     num.tryParse(
                                  //       widget
                                  //               .products!
                                  //               .packInfo![0]
                                  //               .productdetailMrp ??
                                  //           "0",
                                  //     ) ??
                                  //     0;
                                  // final newPackSrp =
                                  //     num.tryParse(
                                  //       packInfoOfSelected!.productdetailSrp ??
                                  //           "0",
                                  //     ) ??
                                  //     0;
                                  // final newPackMrp =
                                  //     num.tryParse(
                                  //       packInfoOfSelected!.productdetailMrp ??
                                  //           "0",
                                  //     ) ??
                                  //     0;

                                  // debugPrint(
                                  //   "===>>> newPackSrp $newPackSrp newPackMrp $newPackMrp srp $srp mrp $mrp",
                                  // );
                                  return Row(
                                    children: [
                                      // TextWiget(
                                      //   title: isNewPack
                                      //       ? '₹$newPackSrp'
                                      //       : '₹$srp ',
                                      //   style: Themes.dark.textTheme.bodyLarge!
                                      //       .copyWith(
                                      //         fontWeight: FontWeight.w600,
                                      //       ),
                                      // ),
                                      // if (isNewPack
                                      //     ? (newPackSrp < newPackMrp)
                                      //     : (srp < mrp))
                                      //   TextWiget(
                                      //     title: isNewPack
                                      //         ? newPackMrp.toString()
                                      //         : '$mrp',
                                      //     style: Themes
                                      //         .dark
                                      //         .textTheme
                                      //         .displayMedium!
                                      //         .copyWith(
                                      //           color: COLOR.grey,
                                      //           fontWeight: FontWeight.normal,
                                      //           decoration:
                                      //               TextDecoration.lineThrough,
                                      //         ),
                                      //   ),
                                      // if (isNewPack
                                      //     ? (newPackSrp < newPackMrp)
                                      //     : (srp < mrp))
                                      //   TextWiget(
                                      //     title:
                                      //         ' ${calculateDiscount(double.parse(isNewPack ? newPackMrp.toString() : mrp.toString()), double.parse(isNewPack ? newPackSrp.toString() : srp.toString())).toInt()} % ${StringRes.off}',
                                      //     style: Themes
                                      //         .dark
                                      //         .textTheme
                                      //         .displayMedium!
                                      //         .copyWith(color: COLOR.green),
                                      //   ),
                                    ],
                                  );
                                },
                              ),
                              // >>>>>>> Stashed changes
                            ],
                          ),
                        ),
                        // GetBuilder<ProductDetailsController>(
                        //   builder: (controller) {
                        //     return isShareLoad
                        //         ? Padding(
                        //             padding: const EdgeInsets.only(
                        //               top: 14,
                        //               left: 4,
                        //               right: 4,
                        //             ),
                        //             child: SizedBox.square(
                        //               dimension: 20,
                        //               child: CircularProgressIndicator(
                        //                 color: COLOR.appBaseColor,
                        //                 strokeWidth: 2,
                        //               ),
                        //             ),
                        //           )
                        //         : IconButtonWidget(
                        //             voidCallback: () async {
                        //               changeSearchLoader(true);
                        //               List<XFile> files = [];
                        //               final allImages =
                        //                   widget.products?.packInfo
                        //                       ?.expand(
                        //                         (e) =>
                        //                             e.productdetailImages ?? [],
                        //                       )
                        //                       .toList() ??
                        //                   [];

                        //               final uniqueImages = allImages
                        //                   .toSet()
                        //                   .toList();

                        //               print(
                        //                 "===>>> images.length ${uniqueImages.length}",
                        //               );
                        //               for (
                        //                 int i = 0;
                        //                 i < uniqueImages.length;
                        //                 i++
                        //               ) {
                        //                 final url = Uri.parse(
                        //                   '$IMAGE_URL${uniqueImages[i]}',
                        //                 );
                        //                 final response = await http.get(url);

                        //                 var dir = await getTemporaryDirectory();

                        //                 File file = await File(
                        //                   '${dir.path}/$i\\myItem.png',
                        //                 ).writeAsBytes(response.bodyBytes);

                        //                 files.add(XFile(file.path));
                        //               }

                        //               final productId =
                        //                   widget.products?.productId ?? '123';
                        //               final webLink =
                        //                   '${ApiService.baseUrl}check_product/$productId';

                        //               final playStoreLink =
                        //                   'https://play.google.com/store/apps/details?id=com.app.jantunashak';
                        //               final appStoreLink =
                        //                   "https://apps.apple.com/app/com.reliable.jantunashakApp";

                        //               final text =
                        //                   'Check out this product: $webLink\n'
                        //                   '\nInstall the app: $playStoreLink';
                        //               final text1 =
                        //                   'Check out this product: $webLink\n'
                        //                   '\nInstall the app: $appStoreLink';

                        //               await Share.shareXFiles(
                        //                 files,
                        //                 text: Platform.isIOS ? text1 : text,
                        //                 subject: 'JantuNashak Product',
                        //               ).then((value) {
                        //                 changeSearchLoader(false);
                        //               });
                        //             },
                        //             icons: Icons.share_outlined,
                        //             color: COLOR.black,
                        //           );
                        //   },
                        // ),
                      ],
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.only(top: 5),
                    //   child: AlignWidget(
                    //     alignment: Alignment.centerLeft,
                    //     child: Container(
                    //       padding: EdgeInsets.symmetric(
                    //         vertical: 5,
                    //         horizontal: 10,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         color: COLOR.greyLight.withOpacity(0.5),
                    //         borderRadius: BorderRadius.circular(5),
                    //       ),
                    //       child: TextWiget(
                    //         title: StringRes.freeDelivery,
                    //         style: Themes.light.textTheme.displayMedium!
                    //             .copyWith(
                    //               fontWeight: FontWeight.w400,
                    //               color: Colors.black,
                    //             ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              // if (widget.products!.qty!.length > 1) ...[
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: COLOR.background,
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      // Quantity selection hidden since QTY array is empty in API
                      // AlignWidget(
                      //   alignment: Alignment.centerLeft,
                      //   child: TextWiget(
                      //     title: StringRes.selectQuantity,
                      //     style: Themes.dark.textTheme.displayMedium!
                      //         .copyWith(
                      //           fontWeight: FontWeight.w600,
                      //           fontSize: 16,
                      //         ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 70,
                      //   child: ListView.builder(
                      //     itemCount: widget.products!.qty!.length,
                      //     scrollDirection: Axis.horizontal,
                      //     itemBuilder: (BuildContext context, int index) {
                      //       final size = widget.products!.qty![index];
                      //       final isSelected = _selectedIndex == index;
                      //       return Padding(
                      //         padding: EdgeInsets.only(top: 08, right: 10),
                      //         child: AlignWidget(
                      //           alignment: Alignment.centerLeft,
                      //           child: ElevatedButton(
                      //             onPressed: () {
                      //               setState(() {
                      //                 _selectedIndex = index;
                      //                 // getIndex(_selectedIndex,
                      //                 //     _selectedColorIndex);
                      //                 getProductInfo(
                      //                   qtySize: widget.products!.qty![index],
                      //                 );
                      //               });
                      //             },
                      //             style: ElevatedButton.styleFrom(
                      //               shape: RoundedRectangleBorder(
                      //                 side: BorderSide(
                      //                   color: isSelected
                      //                       ? COLOR.appBaseColor
                      //                       : COLOR.background,
                      //                 ),
                      //                 borderRadius: BorderRadius.circular(10),
                      //               ),
                      //               backgroundColor: isSelected
                      //                   ? COLOR.appBaseColor
                      //                   : COLOR.background,
                      //             ),
                      //             child: Padding(
                      //               padding: const EdgeInsets.all(0),
                      //               child: FittedBox(
                      //                 child: TextWiget(
                      //                   title: widget.products!.qty![index],
                      //                   style: Themes
                      //                       .light
                      //                       .textTheme
                      //                       .displaySmall!
                      //                       .copyWith(
                      // color: isSelected
                      //                                       // ? COLOR.background
                      //                                       : COLOR.appBaseColor,
                      //                                 ),
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 );
                      //               },
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ],
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: COLOR.background,
                          padding: EdgeInsets.all(05),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AlignWidget(
                                    alignment: Alignment.centerLeft,
                                    child: TextWiget(
                                      title: StringRes.productDetails,
                                      style: Themes
                                          .dark
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                    ),
                                  ),
                                  Divider(height: 10),
                                  InkWell(
                                    onTap: () {
                                      SelectableText(
                                        widget.products!.productDescription!,
                                      );

                                      Clipboard.setData(
                                        ClipboardData(
                                          text: widget
                                              .products!
                                              .productDescription!,
                                        ),
                                      );

                                      final snackBar = SnackBar(
                                        content: TextWiget(
                                          title: StringRes.copyProductDetails,
                                          style: Themes
                                              .light
                                              .textTheme
                                              .displaySmall!
                                              .copyWith(
                                                color: COLOR.background,
                                              ),
                                        ),
                                        action: SnackBarAction(
                                          label: StringRes.undo,
                                          textColor: COLOR.appBaseColor,
                                          onPressed: () {},
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(snackBar);
                                    },
                                    child: TextWiget(
                                      title: StringRes.copy,
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                widget.products!.productDescription!,
                                style: Themes.light.textTheme.displaySmall!
                                    .copyWith(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // bottomNavigationBar: GetBuilder<ProductDetailsController>(
                //   builder: (productDetailsController) {
                //     final productDetailId = isNewPack
                //         ? packInfoOfSelected!.productdetailId!
                //         : productListOFPackInfo[0].productdetailId!;
                //     final isInCart = isProductInCart(productDetailId);

                //     return IntrinsicHeight(
                //       child: ColoredBox(
                //         color: Colors.white,
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Expanded(
                //               child: Container(
                //                 height: 55,
                //                 decoration: BoxDecoration(color: COLOR.green50),
                //                 child: productDetailsController.isLoader.value
                //                     ? Center(
                //                         child: CircularProgressIndicator(
                //                           valueColor: AlwaysStoppedAnimation<Color>(
                //                             COLOR.appBaseColor,
                //                           ),
                //                         ),
                //                       )
                //                     : _buildAddToCartButton(
                //                         context,
                //                         productDetailsController,
                //                         isInCart,
                //                         productDetailId,
                //                       ),
                //               ),
                //             ),
                //             Expanded(
                //               child: _isBuyToCart
                //                   ? Center(
                //                       child: CircularProgressIndicator(
                //                         valueColor: AlwaysStoppedAnimation<Color>(
                //                           COLOR.appBaseColor,
                //                         ),
                //                       ),
                //                     )
                //                   : _buildBuyNowButton(
                //                       context,
                //                       productDetailsController,
                //                       isInCart,
                //                       productDetailId,
                //                     ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     );
                //   },
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(
    BuildContext context,
    ProductDetailsController controller,
    bool isInCart,
    String productDetailId,
  ) {
    // Skip checking packInfo since it's empty - use default false
    final localIsInCart = false;
    // final localIsInCart = isNewPack
    //     ? packInfoOfSelected!.isCart ?? false
    //     : productListOFPackInfo[0].isCart ?? false;

    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: () async {
          if (localIsInCart) {
            Fluttertoast.showToast(msg: StringRes.alreadyInCart);
          } else {
            await _handleAddToCart(controller, productDetailId);
          }
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all(ContinuousRectangleBorder()),
          backgroundColor: WidgetStateProperty.all(
            localIsInCart ? COLOR.grey.withValues(alpha: .2) : COLOR.green50,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: FittedBox(
            child: TextWiget(
              title: localIsInCart
                  ? StringRes.alreadyInCart
                  : StringRes.addtoCart,
              style: TextStyle(
                color: localIsInCart ? COLOR.black : COLOR.appBaseColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBuyNowButton(
    BuildContext context,
    ProductDetailsController controller,
    bool isInCart,
    String productDetailId,
  ) {
    // Skip checking packInfo since it's empty - use default false
    final localIsInCart = false;
    // final localIsInCart = isNewPack
    //     ? packInfoOfSelected!.isCart ?? false
    //     : productListOFPackInfo[0].isCart ?? false;

    return Container(
      height: 55,
      decoration: BoxDecoration(color: COLOR.white),
      child: ElevatedButton(
        onPressed: () async {
          if (localIsInCart) {
            Fluttertoast.showToast(msg: StringRes.alreadyInCart);
            Get.to(() => CartScreen(removeCart: productRemove));
          } else {
            await _handleAddToCart(
              controller,
              productDetailId,
              isFromBuy: true,
            );
            Get.to(() => CartScreen(removeCart: productRemove));
          }
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all(ContinuousRectangleBorder()),
          backgroundColor: WidgetStateProperty.all(COLOR.appBaseColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: FittedBox(
            child: TextWiget(
              title: StringRes.buyNow,
              style: TextStyle(
                color: COLOR.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isAddingToCart = false;
  bool _isBuyToCart = false;

  Future<void> _handleAddToCart(
    ProductDetailsController controller,
    String productDetailId, {
    bool isFromBuy = false,
  }) async {
    if (_isAddingToCart) return;
    if (isFromBuy) {
      _isBuyToCart = true;
    } else {
      _isAddingToCart = true;
    }
    try {
      if (!isFromBuy) controller.isLoader.value = true;
      // Skip setting isCart on packInfo since it's empty
      // if (isNewPack) {
      //   packInfoOfSelected!.isCart = true;
      // } else {
      //   productListOFPackInfo[0].isCart = true;
      // }
      setState(() {});
      controller.update();

      await controller.addToCart(
        widget.products!,
        productDetailId,
        isFromBuy: isFromBuy,
      );

      await cartController.getCartDetails(
        cartController.customerModel!.value.customerId!,
      );
      cartController.update();
    } catch (e) {
      // Skip resetting isCart on packInfo since it's empty
      // if (isNewPack) {
      //   packInfoOfSelected!.isCart = false;
      // } else {
      //   productListOFPackInfo[0].isCart = false;
      // }
      Fluttertoast.showToast(msg: "Failed to add to cart: $e");
    } finally {
      controller.isLoader.value = false;
      setState(() {});
      controller.update();
      _isAddingToCart = false;
      if (isFromBuy) {
        _isBuyToCart = false;
      } else {
        _isAddingToCart = false;
      }
    }
  }

  Widget buildImageShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: EdgeInsets.all(15),
        height: 200,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }

  void getIndex(int sizeIndex, int colorIndex) {
    setState(() {
      print("Hello size $sizeIndex");
      print("Hello color $colorIndex");
    });
  }

  void openBottomSheetDelivery(BuildContext context) {
    Get.bottomSheet(
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.24,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextWiget(
                          title: StringRes.addDeliveryLocation,
                          style: Themes.light.textTheme.displaySmall,
                        ),
                        Expanded(
                          child: AlignWidget(
                            alignment: Alignment.topRight,
                            child: IconButtonWidget(
                              voidCallback: () {
                                // Get.back();
                              },
                              icons: Icons.close,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DividerWidget(thickness: 1),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierColor: COLOR.black.withOpacity(0.8),
      isScrollControlled: true,
      backgroundColor: COLOR.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
    );
  }
}

void showSharingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return GetBuilder<ProductDetailsController>(
        builder: (controller) => AlertDialog(
          backgroundColor: COLOR.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                StringRes.sharingImages,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    controller.isImagesDownloaded
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: controller.isImagesDownloaded
                        ? Colors.green
                        : Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Text(StringRes.images),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    controller.isDescriptionShared
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: controller.isDescriptionShared
                        ? Colors.green
                        : Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Text(StringRes.description),
                ],
              ),
              SizedBox(height: 16),
              LinearProgressIndicator(
                value: controller.downloadProgress,
                color: COLOR.appBaseColor,
                backgroundColor: Colors.grey[300],
              ),
              SizedBox(height: 16),
              Text(
                controller.isSharingDescription
                    ? StringRes.sharingDescription
                    : StringRes.sharingImagesDialog,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ProductImageScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ProductImageScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ProductImageScreen> createState() => _ProductImageScreenState();
}

class _ProductImageScreenState extends State<ProductImageScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final TransformationController _transformationController =
      TransformationController();
  final double _zoomScale = 2.0;

  late List<TransformationController> _controllers;

  late AnimationController animationController;
  Animation<Matrix4>? animation;
  TapDownDetails? tapDownDetails;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controllers = List.generate(
      widget.imageUrls.length,
      (_) => TransformationController(),
    );

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..addListener(() {
            _controllers[_currentIndex].value = animation!.value;
          });
  }

  void _handleDoubleTap(int index) {
    final controller = _controllers[index];
    final position = tapDownDetails?.localPosition ?? Offset.zero;
    final scale = 2.5;

    final zoomed = Matrix4.identity()
      ..translate(-position.dx * (scale - 1), -position.dy * (scale - 1))
      ..scale(scale);

    final endMatrix = controller.value.isIdentity()
        ? zoomed
        : Matrix4.identity();

    animation = Matrix4Tween(begin: controller.value, end: endMatrix).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    animationController.forward(from: 0);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        height: 90,
        appbarPadding: 0,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(Icons.arrow_back_ios, color: COLOR.background, size: 20),
        ),
      ),
      backgroundColor: COLOR.greyLight,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            width: MediaQuery.of(context).size.width,
            child: CarouselSlider.builder(
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index, realIndex) {
                return StatefulBuilder(
                  builder: (context, setLocalState) {
                    return GestureDetector(
                      onDoubleTapDown: (details) => tapDownDetails = details,
                      onDoubleTap: () => _handleDoubleTap(index),
                      child: InteractiveViewer(
                        transformationController: _controllers[index],
                        panEnabled: true,
                        scaleEnabled: true,
                        minScale: 1,
                        maxScale: 4,
                        constrained: true,
                        child: Image.network(
                          '$IMAGE_URL${widget.imageUrls[index]}',
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                );
              },
              options: CarouselOptions(
                viewportFraction: 1,
                height: MediaQuery.of(context).size.height,
                initialPage: widget.initialIndex,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                    for (var c in _controllers) {
                      c.value = Matrix4.identity();
                    }
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      for (var controller in _controllers) {
                        controller.value = Matrix4.identity();
                      }
                      _currentIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentIndex == index ? COLOR.pink : COLOR.grey,
                      ),
                    ),
                    child: Image.network(
                      '$IMAGE_URL${widget.imageUrls[index]}',
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: COLOR.appBaseColor,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 50, color: Colors.red),
                              SizedBox(height: 8),
                              Text(StringRes.failedToLoadImage),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
