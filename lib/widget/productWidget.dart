import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:omkar_app/models/productModel.dart';
import 'package:omkar_app/utils/string_res.dart';
import 'package:omkar_app/widget/productDetailView.dart';
import 'package:omkar_app/widget/textWidget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../Theme/nativeTheme.dart';
import '../constant/app_constant.dart';
import '../constant/colorConst.dart';
import '../controller/homeController.dart';
import '../controller/shareProductsController.dart';
import '../utils/services/api_services.dart';

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
    double heightView = (MediaQuery.of(context).size.height * 18) / 100;
    if (widget.products?.productId == "82") {
      widget.products?.packInfo?.forEach((element) {
        print(
          "=======>>>> widget.products?.productId ${widget.products?.productId} ${element.toJson()}",
        );
      });
    }

    return InkWell(
      onTap: () {
        print(
          "=====>>> Product Tap ${widget.products?.productId} ${widget.products?.productName}",
        );
        Get.to(
          () => ProductDetailScreen(
            products: widget.products!,
            isExpanded: true,
            fromDeepLink: false,
          ),
          transition: Transition.rightToLeftWithFade,
        );
      },
      child: SizedBox(
        width: widget.fromVideoScreen
            ? MediaQuery.sizeOf(context).width * 0.4
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            AspectRatio(
              aspectRatio: 4 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    // IMAGE
                    Positioned.fill(
                      child:
                          widget.products?.productImage?.isNotEmpty == true &&
                              widget.products!.productImage?.isNotEmpty == true
                          ? CachedNetworkImage(
                              imageUrl:
                                  '$IMAGE_URL${widget.products?.productImage}',
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: Colors.grey.shade200),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: Opacity(
                                  opacity:
                                      0.8, // 0.0 = fully transparent, 1.0 = fully visible
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    width: 100,
                                    height: 100,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          : widget.products?.productImage != null
                          ? CachedNetworkImage(
                              imageUrl:
                                  '$IMAGE_URL${widget.products!.productImage!}',
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: Colors.grey.shade200),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: Opacity(
                                  opacity: 0.8,
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    width: 100,
                                    height: 100,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          : Opacity(
                              opacity:
                                  0.8, // 0.0 = fully transparent, 1.0 = fully visible
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 100,
                                height: 100,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                    ),

                    // BLACK GRADIENT (bottom fade)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                    ),

                    // TEXT (bottom center)
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: Text(
                        widget.products!.productName ?? '',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // const SizedBox(height: 8),

            // // TITLE
            // Text(
            //   widget.products!.productName ?? '',
            //   maxLines: 2,
            //   overflow: TextOverflow.ellipsis,
            //   style: TextStyle(
            //     fontSize: 14,
            //     fontWeight: FontWeight.w600,
            //     height: 1.3,
            //     color: Colors.black87,
            //   ),
            // ),
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
