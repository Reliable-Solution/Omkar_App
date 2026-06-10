import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../constant/colorConst.dart';
import '../controller/homeController.dart';
import '../controller/shareProductsController.dart';
import '../models/productModel.dart';
import '../constant/app_constant.dart';
import 'productDetailView.dart';

class ProductComponent extends StatefulWidget {
  final Color color;

  const ProductComponent({
    super.key,
    @required this.products,
    this.color = Colors.white,
    this.fromVideoScreen = false,
  });

  final ProductModel? products;
  final bool fromVideoScreen;

  @override
  State<ProductComponent> createState() => _ProductComponentState();
}

class _ProductComponentState extends State<ProductComponent> {
  Color? color;

  final ShareProductController controller = Get.find();

  final HomeController homeController = Get.find();
  bool isShareLoad = false;

  double calculateDiscount(double mrp, double srp) {
    print('Invalid MRP or SRP values $mrp $srp');
    if (mrp <= 0) {
      throw Exception("Invalid MRP or SRP values $mrp $srp");
    }
    double discount = ((mrp - srp) / mrp) * 100;
    return discount;
  }

  void changeSearchLoader(bool value) {
    setState(() => isShareLoad = value);
  }

  @override
  Widget build(BuildContext context) {
    String? imageUrl =
        (widget.products?.productImage != null &&
            widget.products!.productImage!.isNotEmpty)
        ? widget.products?.productImage
        : (widget.products?.packInfo != null &&
              widget.products!.packInfo!.isNotEmpty &&
              widget.products!.packInfo![0].productdetailImages != null &&
              widget.products!.packInfo![0].productdetailImages!.isNotEmpty)
        ? widget.products!.packInfo![0].productdetailImages![0]
        : null;

    String? price =
        (widget.products?.packInfo != null &&
            widget.products!.packInfo!.isNotEmpty)
        ? widget.products!.packInfo![0].productdetailSrp
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      splashColor: COLOR.appBaseColor.withOpacity(0.1),
      highlightColor: COLOR.appBaseColor.withOpacity(0.05),
      onTap: () {
        Get.to(
          () => ProductDetailScreen(
            products: widget.products!,
            isExpanded: true,
            fromDeepLink: false,
          ),
          transition: Transition.rightToLeftWithFade,
        );
      },
      child: Container(
        height: 400,
        margin: const EdgeInsets.symmetric(vertical: 3),
        // padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            // Deep 3D-style shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              // blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 4),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Added for tighter fit
          children: [
            // Image Section
            AspectRatio(
              aspectRatio: 0.89,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    // Deep 3D-style shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: '$IMAGE_URL$imageUrl',
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey[200]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(color: Colors.white),
                                    ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                      'assets/images/logo.png',
                                      scale: 4,
                                    ),
                              )
                            : Image.asset('assets/images/logo.png', scale: 4),
                      ),
                    ),
                    // Add Icon Button (Premium Style)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: COLOR.appBaseColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: COLOR.appBaseColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 06),
            // Product Details
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 05),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.products?.productName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                  // Text(
                  //   price != null ? "₹ $price" : '',
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: const TextStyle(
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black,
                  //   ),
                  // ),
                ],
              ),
                            ),
            ),
            const SizedBox(height: 06),
          ],
        ),
      ),
    );
  }
}

// class ProductComponent extends StatefulWidget {
//   final Color color;

//   const ProductComponent({
//     super.key,
//     @required this.products,
//     this.color = Colors.white,
//     this.fromVideoScreen = false,
//   });

//   final ProductModel? products;
//   final bool fromVideoScreen;

//   @override
//   State<ProductComponent> createState() => _ProductComponentState();
// }

// class _ProductComponentState extends State<ProductComponent> {
//   Color? color;

//   final ShareProductController controller = Get.find();

//   final HomeController homeController = Get.find();
//   bool isShareLoad = false;

//   double calculateDiscount(double mrp, double srp) {
//     print('Invalid MRP or SRP values $mrp $srp');
//     if (mrp <= 0) {
//       throw Exception("Invalid MRP or SRP values $mrp $srp");
//     }
//     double discount = ((mrp - srp) / mrp) * 100;
//     return discount;
//   }

//   void changeSearchLoader(bool value) {
//     setState(() => isShareLoad = value);
//   }

//   @override
//   Widget build(BuildContext context) {
//     double heightView = (MediaQuery.of(context).size.height * 18) / 100;
//     if (widget.products?.productId == "82") {
//       widget.products?.packInfo?.forEach((element) {
//         print(
//           "=======>>>> widget.products?.productId ${widget.products?.productId} ${element.toJson()}",
//         );
//       });
//     }

//     return InkWell(
//       onTap: () {
//         Get.to(
//           () => ProductDetailScreen(
//             products: widget.products!,
//             isExpanded: true,
//             fromDeepLink: false,
//           ),
//           transition: Transition.rightToLeftWithFade,
//         );
//       },
//       child: Container(
//         width: widget.fromVideoScreen
//             ? MediaQuery.sizeOf(context).width * 0.4
//             : null,
//         // width: MediaQuery.sizeOf(context).width * 0.5,
//         alignment: Alignment.center,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             SizedBox(
//               width: double.infinity,
//               height: heightView,
//               // color: Colors.black,
//               child: Stack(
//                 alignment: Alignment.topRight,
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child:
//                         widget.products?.packInfo?.isNotEmpty == true &&
//                             widget
//                                     .products!
//                                     .packInfo![0]
//                                     .productdetailImages
//                                     ?.isNotEmpty ==
//                                 true
//                         ? CachedNetworkImage(
//                             imageUrl:
//                                 '$IMAGE_URL${widget.products!.packInfo![0].productdetailImages![0]}',
//                             height: heightView,
//                             width: double.infinity,
//                             fit: BoxFit.fitHeight,
//                             placeholder: (context, url) => Shimmer.fromColors(
//                               baseColor: Colors.grey[300]!,
//                               highlightColor: Colors.grey[100]!,
//                               child: Container(
//                                 height: heightView,
//                                 width: double.infinity,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             errorWidget: (context, url, error) => Center(
//                               child: Icon(
//                                 Icons.broken_image,
//                                 color: Colors.red,
//                                 size: 50,
//                               ),
//                             ),
//                           )
//                         : Icon(
//                             Icons.image_not_supported,
//                             size: heightView,
//                             color: Colors.grey,
//                           ),
//                   ),
//                   // Padding(
//                   //   padding: const EdgeInsets.only(right: 2),
//                   //   child: InkWell(
//                   //     onTap: () async {
//                   //       changeSearchLoader(true);
//                   //       List<XFile> files = [];

//                   //       final imageUrl =
//                   //           '$IMAGE_URL${widget.products!.packInfo![0].productdetailImages![0]}';
//                   //       final response = await http.get(Uri.parse(imageUrl));

//                   //       if (response.statusCode == 200) {
//                   //         try {
//                   //           // Get the temporary directory
//                   //           final directory = await getTemporaryDirectory();
//                   //           // Create a file with a unique name
//                   //           final fileName =
//                   //               'product_${DateTime.now().millisecondsSinceEpoch}.png';
//                   //           final file = File('${directory.path}/$fileName');

//                   //           // Write the image data to the file
//                   //           await file.writeAsBytes(response.bodyBytes);

//                   //           // Create XFile from the saved file
//                   //           final xFile = XFile(file.path);
//                   //           files.add(xFile);

//                   //           print("===>>> Image saved to: ${file.path}");
//                   //         } catch (e) {
//                   //           print("===>>> Error saving image: $e");
//                   //         }
//                   //       } else {
//                   //         print(
//                   //           "===>>> Failed to download image. Status code: ${response.statusCode}",
//                   //         );
//                   //       }
//                   //       final productId = widget.products?.productId ?? '123';
//                   //       // final deepLink =
//                   //       //     'jantunashak://product/$productId';
//                   //       final webLink =
//                   //           '${ApiService.baseUrl}check_product/$productId';

//                   //       // Uri newLink =  Uri.parse(deepLink);
//                   //       final playStoreLink =
//                   //           'https://play.google.com/store/apps/details?id=com.app.jantunashak';

//                   //       final text =
//                   //           'Check out this product: $webLink\n\nInstall the app: $playStoreLink';
//                   //       final appStoreLink =
//                   //           "https://apps.apple.com/app/com.app.jantunashakApp";

//                   //       final text1 =
//                   //           'Check out this product: $webLink\n'
//                   //           '\nInstall the app: $appStoreLink';

//                   //       // Share.share(
//                   //       //   'Check out this product: $deepLink\nInstall app: $playStoreLink',
//                   //       // );

//                   //       await Share.shareXFiles(
//                   //         files,
//                   //         text: Platform.isIOS ? text1 : text,
//                   //         subject: 'JantuNashak Product',
//                   //         // files,
//                   //         //     text:
//                   //         //         "Check out this product: $deepLink\nInstall app: $playStoreLink",
//                   //         //     subject: "Data"
//                   //       ).then((value) {
//                   //         // Share.share(
//                   //         //   'Check out this product: $deepLink\nInstall app: $playStoreLink',
//                   //         // );

//                   //         changeSearchLoader(false);
//                   //       });
//                   //     },
//                   //     child: CircleAvatar(
//                   //       backgroundColor: Colors.transparent,
//                   //       child: Icon(Icons.share_outlined),
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//               child: Container(
//                 padding: EdgeInsets.only(bottom: 5),
//                 alignment: Alignment.center,
//                 child: TextWiget(
//                   title: '${widget.products!.productName}',
//                   style: Themes.light.textTheme.bodyMedium!.copyWith(
//                     fontSize: 15,
//                     color: COLOR.black,
//                     fontWeight: FontWeight.w800,
//                     //     fontFamily: 'GentiumPlus'
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
