// flutter

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omkar_app/constant/app_constant.dart';
import 'package:omkar_app/controller/cartController.dart';
import 'package:omkar_app/controller/dashboardController.dart';
import 'package:omkar_app/controller/editController.dart';
import 'package:omkar_app/widget/productWidget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../constant/colorConst.dart';
import '../../constant/imagesConst.dart';
import '../../controller/homeController.dart';
import '../../controller/languageController.dart';
import '../../controller/productDetailController.dart';
import '../../theme/nativeTheme.dart';
import '../../utils/sharedPrefs.dart';
import '../../utils/string_res.dart';
import '../../widget/service_shimmer.dart';
import '../../widget/textWidget.dart';
import 'package:omkar_app/view/otp/phone_auth.dart';

import '../coinHistory_screen/coinHistory_screen.dart';
import '../faq/faq_screen.dart';
import '../account/qr_scanner_view.dart';
import '../redeem/withdraw_point_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final HomeController _controller = Get.put(HomeController());

  // ensure registration
  final CartController cartController = Get.put(CartController());
  final RxString selectedLang = "English".obs;

  ProductDetailsController productDetailsController = Get.find();

  EditProfileController editProfileController = Get.find();

  final LanguageController languageController = Get.find<LanguageController>();

  final List<String> searchLabels = [
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

  productRemove() {
    productDetailsController.isCart = false;
    productDetailsController.update();
  }

  final ScrollController _scrollController = ScrollController();
  final RxBool _showSliverAppBar = false.obs;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    languageController.loadLanguage();
  }

  void _onScroll() {
    // Example: hide something after 100px
    if (_scrollController.position.pixels > 100) {
      setState(() {
        _showSliverAppBar.value = true;
      });
    } else {
      setState(() {
        _showSliverAppBar.value = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: COLOR.greyLight,
        // drawer: Drawer(),
        body: GetBuilder<HomeController>(
          builder: (controller) {
            return RefreshIndicator(
              edgeOffset: 110, // Push indicator below AppBar
              onRefresh: () async {
                await controller.refreshDashboard();
              },
              child: CustomScrollView(
                controller: _scrollController, // <- attach here
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverAppBar(
                    leading: SizedBox(),
                    backgroundColor: COLOR.appBaseColor,
                    actionsPadding: EdgeInsets.symmetric(horizontal: 10),
                    snap: false,
                    pinned: true,
                    floating: false,
                    toolbarHeight: 70,
                    // Bada kar diya
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                          left: 10,
                          right: 10,
                        ),
                        child: Row(
                          children: [
                            Builder(
                              builder: (context) => InkWell(
                                onTap: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                child: Obx(() {
                                  final imagePath = editProfileController
                                      .m1
                                      .value
                                      ?.customerImage;
                                  return Container(
                                    height: 40,
                                    width: 40,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image:
                                            (imagePath != null &&
                                                imagePath.isNotEmpty)
                                            ? NetworkImage(
                                                    imagePath.startsWith('http')
                                                        ? imagePath
                                                        : "$IMAGE_URL$imagePath",
                                                  )
                                                  as ImageProvider
                                            : AssetImage(Images.profileicon),
                                        fit: BoxFit.cover,
                                      ),
                                      shape: BoxShape.circle,
                                      color: COLOR.greyLight,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              child: Obx(
                                () => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWiget(
                                      title: _controller.customerModel != null
                                          ? "${StringRes.hello} ${editProfileController.m1.value!.customerName!}"
                                          : StringRes.hello,
                                      maxLines: 1,
                                      style: Themes
                                          .light
                                          .textTheme
                                          .displayMedium
                                          ?.copyWith(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      "Welcome back!",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Redeem Points Icon
                            Obx(
                              () =>
                                  editProfileController.m1.value?.role ==
                                      "carpenter"
                                  ? IconButton(
                                      onPressed: () => Get.to(
                                        () => const WithdrawPointScreen(),
                                      ),
                                      icon: const Icon(
                                        Icons.redeem_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    )
                                  : const SizedBox(),
                            ),
                            // QR Scan Icon
                            Obx(
                              () =>
                                  editProfileController.m1.value?.role ==
                                      "carpenter"
                                  ? IconButton(
                                      onPressed: () =>
                                          Get.to(() => const QRScannerView()),
                                      icon: const Icon(
                                        Icons.qr_code_scanner_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    )
                                  : const SizedBox(),
                            ),

                            // GetBuilder<HomeController>(
                            //   builder: (controller) => InkWell(
                            //     onTap: () {
                            //       Get.to(
                            //         CoinHistoryScreen(),
                            //         transition: Transition.fade,
                            //       );
                            //     },
                            //     child: Container(
                            //       height: 30,
                            //       padding: const EdgeInsets.symmetric(
                            //         horizontal: 10,
                            //       ),
                            //       alignment: Alignment.center,
                            //       decoration: const BoxDecoration(
                            //         color: Colors.white,
                            //         borderRadius: BorderRadius.horizontal(
                            //           right: Radius.circular(10),
                            //           left: Radius.circular(10),
                            //         ),
                            //       ),
                            //       child: Row(
                            //         mainAxisAlignment:
                            //             MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           Icon(
                            //             Icons.wallet,
                            //             size: 18,
                            //             color: COLOR.appBaseColor,
                            //           ),
                            //           const SizedBox(width: 2),
                            //           Text(
                            //             editProfileController
                            //                         .m1
                            //                         .value
                            //                         ?.points ==
                            //                     null
                            //                 ? "0"
                            //                 : "${editProfileController.m1.value!.points}",
                            //             style: const TextStyle(
                            //               fontSize: 16,
                            //               color: Colors.black,
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // SliverPersistentHeader(
                  //   floating: false,
                  //   pinned: true,
                  //   delegate: SliverAppBarDelegate(
                  //     child: PreferredSize(
                  //       preferredSize: Size.fromHeight(65),
                  //       child: GetBuilder<HomeController>(
                  //         builder: (controller) => Container(
                  //           color: COLOR.appBaseColor,
                  //           padding: EdgeInsets.only(
                  //             top: 7,
                  //             bottom: 7,
                  //             right: 16,
                  //             left: 16,
                  //           ),
                  //           child: Row(
                  //             children: [
                  //               Expanded(
                  //                 child: InkWell(
                  //                   onTap: () {
                  //                     controller.searchList.clear();
                  //                     controller.blogList.clear();
                  //                     controller.searchController.clear();
                  //                     Get.to(() => SearchScreen());
                  //                   },
                  //                   child: Container(
                  //                     width: MediaQuery.of(
                  //                       Get.context!,
                  //                     ).size.width,
                  //                     color: COLOR.appBaseColor,
                  //                     child: Card(
                  //                       elevation: 0,
                  //                       child: Container(
                  //                         width: MediaQuery.of(
                  //                           Get.context!,
                  //                         ).size.width,
                  //                         height:
                  //                             MediaQuery.of(
                  //                               Get.context!,
                  //                             ).size.height *
                  //                             0.07,
                  //                         padding: EdgeInsets.symmetric(
                  //                           horizontal: 10,
                  //                         ),
                  //                         decoration: BoxDecoration(
                  //                           color: COLOR.background,
                  //                           borderRadius:
                  //                               BorderRadius.circular(10),
                  //                           border: Border.all(
                  //                             color: COLOR.grey,
                  //                             width: 1,
                  //                           ),
                  //                         ),
                  //                         child: Row(
                  //                           crossAxisAlignment:
                  //                               CrossAxisAlignment.center,
                  //                           children: [
                  //                             Row(
                  //                               crossAxisAlignment:
                  //                                   CrossAxisAlignment
                  //                                       .center,
                  //                               children: [
                  //                                 Icon(
                  //                                   Icons.search,
                  //                                   size: 25,
                  //                                   color: COLOR.grey,
                  //                                 ),
                  //                                 SizedBox(width: 4),
                  //                                 GetBuilder<
                  //                                   HomeController
                  //                                 >(
                  //                                   builder: (controller) => AnimatedSwitcher(
                  //                                     duration: Duration(
                  //                                       milliseconds: 600,
                  //                                     ),
                  //                                     transitionBuilder:
                  //                                         (
                  //                                           Widget child,
                  //                                           Animation<
                  //                                             double
                  //                                           >
                  //                                           animation,
                  //                                         ) {
                  //                                           final isNew =
                  //                                               child
                  //                                                   .key ==
                  //                                               ValueKey<
                  //                                                 String
                  //                                               >(
                  //                                                 controller
                  //                                                     .searchLabels[controller
                  //                                                     .currentLabelIndex
                  //                                                     .value],
                  //                                               );
                  //                                           debugPrint(
                  //                                             "==========>Language ${controller.searchLabels[controller.currentLabelIndex.value]}",
                  //                                           );
                  //                                           final offsetTween =
                  //                                               isNew
                  //                                               ? Tween<
                  //                                                   Offset
                  //                                                 >(
                  //                                                   begin: Offset(
                  //                                                     0,
                  //                                                     0.6,
                  //                                                   ),
                  //                                                   end: Offset(
                  //                                                     0,
                  //                                                     0,
                  //                                                   ),
                  //                                                 )
                  //                                               : Tween<
                  //                                                   Offset
                  //                                                 >(
                  //                                                   begin: Offset(
                  //                                                     0,
                  //                                                     0,
                  //                                                   ),
                  //                                                   end: Offset(
                  //                                                     0,
                  //                                                     -0.0,
                  //                                                   ),
                  //                                                 );
                  //
                  //                                           return SlideTransition(
                  //                                             position: offsetTween.animate(
                  //                                               CurvedAnimation(
                  //                                                 parent:
                  //                                                     animation,
                  //                                                 curve: Curves
                  //                                                     .easeInOutCubic,
                  //                                                 reverseCurve:
                  //                                                     Curves.easeInOutCubic,
                  //                                               ),
                  //                                             ),
                  //                                             child: FadeTransition(
                  //                                               opacity: CurvedAnimation(
                  //                                                 parent:
                  //                                                     animation,
                  //                                                 curve:
                  //                                                     isNew
                  //                                                     ? Interval(
                  //                                                         0.2,
                  //                                                         1.0,
                  //                                                         curve: Curves.easeIn,
                  //                                                       )
                  //                                                     : Interval(
                  //                                                         0.0,
                  //                                                         0.8,
                  //                                                         curve: Curves.easeOut,
                  //                                                       ),
                  //                                               ),
                  //                                               child:
                  //                                                   child,
                  //                                             ),
                  //                                           );
                  //                                         },
                  //                                     layoutBuilder:
                  //                                         (
                  //                                           Widget?
                  //                                           currentChild,
                  //                                           List<Widget>
                  //                                           previousChildren,
                  //                                         ) {
                  //                                           return Stack(
                  //                                             clipBehavior:
                  //                                                 Clip.hardEdge,
                  //                                             alignment:
                  //                                                 Alignment
                  //                                                     .centerLeft,
                  //                                             children: [
                  //                                               if (currentChild !=
                  //                                                   null)
                  //                                                 currentChild,
                  //                                             ],
                  //                                           );
                  //                                         },
                  //                                     child: TextWiget(
                  //                                       key: ValueKey<String>(
                  //                                         controller
                  //                                             .searchLabels[controller
                  //                                             .currentLabelIndex
                  //                                             .value],
                  //                                       ),
                  //                                       title:
                  //                                           "Search Product",
                  //
                  //                                       style: TextStyle(
                  //                                         fontSize: 15,
                  //                                         fontWeight:
                  //                                             FontWeight
                  //                                                 .w500,
                  //                                         color: Colors
                  //                                             .black,
                  //                                       ),
                  //                                     ),
                  //                                   ),
                  //                                 ),
                  //                               ],
                  //                             ),
                  //                           ],
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Container(
                        color: COLOR.background,
                        // margin: EdgeInsets.all(1),
                        padding: EdgeInsets.all(6),
                        width: MediaQuery.of(context).size.width,
                        child: GetBuilder<HomeController>(
                          builder: (controller) {
                            if (controller.isDashBoardLoading.value ||
                                controller.offerList.isEmpty) {
                              return ServicesShimmer();
                            }

                            if (controller.offerList.isEmpty &&
                                controller.productList.isEmpty) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: Center(
                                  child: Text(
                                    "No data available. Pull down to refresh.",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: [
                                ///  DashBoard category
                                // Container(
                                //   height:
                                //       MediaQuery.of(
                                //         context,
                                //       ).size.height *
                                //       0.15,
                                //   width: MediaQuery.of(
                                //     context,
                                //   ).size.width,
                                //   padding:
                                //       const EdgeInsets.symmetric(
                                //         horizontal: 10.0,
                                //         vertical: 10,
                                //       ),
                                //   // Add padding for better look
                                //   child: ListView.builder(
                                //     scrollDirection:
                                //         Axis.horizontal,
                                //     // shrinkWrap: true,
                                //     // physics: NeverScrollableScrollPhysics(),
                                //     // gridDelegate:
                                //     // SliverGridDelegateWithFixedCrossAxisCount(
                                //     //   crossAxisCount: 3,
                                //     //   childAspectRatio: 1.6 / 2,
                                //     // ),
                                //     itemCount: controller
                                //         .categoryList
                                //         .length,
                                //     itemBuilder: (context, index) {
                                //       return Padding(
                                //         padding:
                                //             const EdgeInsets.only(
                                //               right: 10.0,
                                //             ),
                                //         child: CategoryComponent(
                                //           categoryModel: controller
                                //               .categoryList[index],
                                //         ),
                                //       );
                                //     },
                                //   ),
                                // ),

                                ///  DashBoard offers
                                controller.offerList.isEmpty
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          width: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          color: COLOR.background,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                    ),
                                                child: SizedBox(
                                                  height:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height *
                                                      0.19,
                                                  width: MediaQuery.of(
                                                    context,
                                                  ).size.width,
                                                  child: CarouselSlider.builder(
                                                    itemCount: controller
                                                        .offerList
                                                        .length,
                                                    itemBuilder: (context, index, realIndex) {
                                                      return Container(
                                                        margin:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 5,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              COLOR.pinkLight,
                                                          image: DecorationImage(
                                                            image: NetworkImage(
                                                              '$IMAGE_URL${controller.offerList[index].offerImage}',
                                                            ),
                                                            fit: BoxFit.fill,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    options: CarouselOptions(
                                                      enlargeCenterPage: false,
                                                      autoPlay: true,
                                                      onPageChanged:
                                                          (index, reason) {
                                                            controller
                                                                    .activeIndex
                                                                    .value =
                                                                index;
                                                            controller.update();
                                                          },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 5,
                                                ),
                                                child: buildIndicator(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ],
                            );
                          },
                        ),
                      ),
                    ]),
                  ),
                  if (controller.productList.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        // margin: EdgeInsets.only(
                        //   top: 10,
                        //   bottom: 10,
                        // ),
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 13,
                          bottom: 13,
                        ),
                        // Reduced vertical padding
                        // padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                        // color: Color(0xFFF5E6F5),
                        color: COLOR.background,

                        // Match with grid background
                        child: Text(
                          StringRes.products,
                          // 'Top Picks for You',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            // color: Color(0xff900C3F),
                          ),
                        ),
                      ),
                    ),

                  if (controller.productList.isNotEmpty)
                    GetBuilder<HomeController>(
                      builder: (controller) {
                        return SliverToBoxAdapter(
                          child: Column(
                            children: [
                              Container(
                                // color: COLOR.appBaseColor.withOpacity(0.2),
                                color: COLOR.background.withOpacity(0.8),
                                padding: EdgeInsets.only(
                                  top: 0,
                                  left: 8.0,
                                  right: 8.0,
                                  bottom: 8.0,
                                ),
                                child: GridView.builder(
                                  itemCount: controller.productList.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.64,
                                        mainAxisExtent: 252,
                                        // Adjust based on your height/width ratio
                                        crossAxisSpacing: 8.0,
                                        mainAxisSpacing: 9.0,
                                      ),
                                  itemBuilder: (context, index) {
                                    final products =
                                        controller.productList[index];
                                    return ProductComponent(
                                      products: products,
                                      color: Colors.green,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  // GetBuilder<HomeController>(
                  //   builder: (controller) {
                  //     return SliverList(
                  //       delegate: SliverChildBuilderDelegate((
                  //         context,
                  //         index,
                  //       ) {
                  //         final tag = controller.tagProductList[index];
                  //         final seenIds = <String>{};
                  //         final uniqueProducts = (tag.products ?? [])
                  //             .where(
                  //               (p) =>
                  //                   p.productId != null &&
                  //                   seenIds.add(p.productId!),
                  //             )
                  //             .toList();
                  //         return Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             // Tag Header
                  //             Container(
                  //               constraints: BoxConstraints(
                  //                 maxHeight:
                  //                     MediaQuery.of(context).size.height *
                  //                     0.25,
                  //               ),
                  //               alignment: Alignment.center,
                  //               color: Colors.white,
                  //               child: Padding(
                  //                 padding: const EdgeInsets.symmetric(
                  //                   horizontal: 5,
                  //                   vertical: 10,
                  //                 ),
                  //                 child: tag.tagImage != null
                  //                     ? Image.network(
                  //                         width: double.infinity,
                  //                         IMAGE_URL + tag.tagImage!,
                  //                         fit: BoxFit.contain,
                  //                       )
                  //                     : Image.asset(
                  //                         'assets/images/nomoreweed.jpg',
                  //                         fit: BoxFit.cover,
                  //                       ),
                  //               ),
                  //             ),
                  //             if (uniqueProducts.isNotEmpty)
                  //               Container(
                  //                 width: 900,
                  //                 padding: EdgeInsets.only(
                  //                   left: 10,
                  //                   right: 20,
                  //                   top: 10,
                  //                   bottom: 10,
                  //                 ),
                  //                 color: index == 0
                  //                     ? Colors.orange.shade200.withValues(
                  //                         alpha: .1,
                  //                       )
                  //                     : index == 1
                  //                     ? Colors.blue.shade200.withValues(
                  //                         alpha: .1,
                  //                       )
                  //                     : index == 2
                  //                     ? Colors.green.shade200.withValues(
                  //                         alpha: .1,
                  //                       )
                  //                     : Colors.white,
                  //                 // Color(0xffcfdbfa),
                  //                 child: Text(
                  //                   tag.tagName ?? 'Tag ${index + 1}',
                  //                   style: TextStyle(
                  //                     fontSize: 24,
                  //                     fontWeight: FontWeight.w500,
                  //                     color: Colors.black,
                  //                   ),
                  //                 ),
                  //               ),

                  //             // Tag Products Grid
                  //             if (uniqueProducts.isNotEmpty)
                  //               Container(
                  //                 color: index == 0
                  //                     ? Colors.orange.shade200.withValues(
                  //                         alpha: .1,
                  //                       )
                  //                     : index == 1
                  //                     ? Colors.blue.shade200.withValues(
                  //                         alpha: .1,
                  //                       )
                  //                     : index == 2
                  //                     ? Colors.green.shade200.withValues(
                  //                         alpha: .1,
                  //                       )
                  //                     : Colors.white,
                  //                 padding: EdgeInsets.only(
                  //                   top: 0,
                  //                   left: 8.0,
                  //                   right: 8.0,
                  //                   bottom: 8.0,
                  //                 ),
                  //                 child: GridView.builder(
                  //                   itemCount: uniqueProducts.length,
                  //                   // tag.products?.length ?? 0,
                  //                   shrinkWrap: true,
                  //                   physics:
                  //                       NeverScrollableScrollPhysics(),
                  //                   gridDelegate:
                  //                       const SliverGridDelegateWithFixedCrossAxisCount(
                  //                         crossAxisCount: 2,
                  //                         childAspectRatio: 0.65,
                  //                         crossAxisSpacing: 2,
                  //                         mainAxisSpacing: 0,
                  //                       ),
                  //                   itemBuilder: (context, productIndex) {
                  //                     // final product =
                  //                     //     tag.products![productIndex];
                  //                     // final productModel =
                  //                     //     ProductModel.fromJson(
                  //                     //         product.toJson()); // 🔄 Converted

                  //                     final product =
                  //                         uniqueProducts[productIndex];
                  //                     final productModel =
                  //                         ProductModel.fromJson(
                  //                           product.toJson(),
                  //                         );

                  //                     return ProductComponent(
                  //                       color: index == 0
                  //                           ? Colors.orange.shade200
                  //                           : index == 1
                  //                           ? Colors.blue.shade200
                  //                           : index == 2
                  //                           ? Colors.green.shade200
                  //                           : Colors.white,
                  //                       products: productModel,
                  //                     );
                  //                   },
                  //                 ),
                  //               ),
                  //           ],
                  //         );
                  //       }, childCount: controller.tagProductList.length),
                  //     );
                  //   },
                  // ),
                  // if (controller.diseaseProductList.isNotEmpty)
                  //   SliverToBoxAdapter(
                  //     child: Container(
                  //       padding: EdgeInsets.only(
                  //         left: 15,
                  //         right: 20,
                  //         top: 10,
                  //       ),
                  //       // Reduced vertical padding
                  //       // padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  //       // color: Color(0xFFF5E6F5),
                  //       // color: Colors.green.withOpacity(0.2),

                  //       // Match with grid background
                  //       child: Text(
                  //         StringRes.solutionsToPestsAndDiseases,
                  //         // "Solutions to Pests and Diseases",
                  //         // StringRes.topPicksForYou,
                  //         // 'Top Picks for You',
                  //         style: TextStyle(
                  //           fontSize: 20,
                  //           fontWeight: FontWeight.w500,
                  //           color: Colors.black,
                  //           // color: Color(0xff900C3F),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(5.0),
                  //     child: GridView.builder(
                  //       gridDelegate:
                  //           SliverGridDelegateWithFixedCrossAxisCount(
                  //             crossAxisCount: 3,
                  //             crossAxisSpacing: 12,
                  //             mainAxisSpacing: 10,
                  //             childAspectRatio: 0.85,
                  //           ),
                  //       shrinkWrap: true,
                  //       physics: NeverScrollableScrollPhysics(),
                  //       itemCount: controller.diseaseProductList.length,
                  //       itemBuilder: (context, index) {
                  //         return InkWell(
                  //           onTap: () {
                  //             if (controller
                  //                     .diseaseProductList[index]
                  //                     .diseasesId !=
                  //                 null) {
                  //               final diseaseProducts =
                  //                   controller
                  //                       .diseaseProductList[index]
                  //                       .products ??
                  //                   [];
                  //               // debugPrint("=======> ${controller.diseaseProductList[index].products}");
                  //               // final product =controller.diseaseProductList[index].products![index];
                  //               // uniqueProducts[productIndex];
                  //               // final productModel =
                  //               // ProductModel.fromJson(
                  //               //     product.toJson());
                  //               // final dieaseList = controller.diseaseProductList[index].products;
                  //               Get.to(
                  //                 DiseaseScreen(
                  //                   productList: diseaseProducts ?? [],
                  //                   dieaseName:
                  //                       controller
                  //                           .diseaseProductList[index]
                  //                           .diseasesName ??
                  //                       "",
                  //                 ),
                  //                 // SubCategoryScreen(
                  //                 //     category: controller.categoryList[index].categoryId),
                  //                 transition: Transition.zoom,
                  //               );
                  //             }
                  //           },
                  //           child: Container(
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(12),
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                   color: Colors.black.withOpacity(0.1),
                  //                   blurRadius: 4,
                  //                   offset: Offset(0, 2),
                  //                 ),
                  //               ],
                  //             ),
                  //             child: ClipRRect(
                  //               borderRadius: BorderRadius.circular(12),
                  //               child: Stack(
                  //                 fit: StackFit.expand,
                  //                 children: [
                  //                   // Background Image
                  //                   Image.network(
                  //                     "$IMAGE_URL${controller.diseaseProductList[index].diseasesImage}",
                  //                     fit: BoxFit.cover,
                  //                     errorBuilder:
                  //                         (context, error, stackTrace) {
                  //                           return Container(
                  //                             color: Colors.grey[300],
                  //                             child: Icon(
                  //                               Icons.broken_image,
                  //                               color: Colors.grey[600],
                  //                               size: 40,
                  //                             ),
                  //                           );
                  //                         },
                  //                     loadingBuilder: (context, child, loadingProgress) {
                  //                       if (loadingProgress == null) {
                  //                         return child;
                  //                       }
                  //                       return Container(
                  //                         color: Colors.grey[300],
                  //                         child: Center(
                  //                           child: CircularProgressIndicator(
                  //                             color: COLOR.appBaseColor,
                  //                             value:
                  //                                 loadingProgress
                  //                                         .expectedTotalBytes !=
                  //                                     null
                  //                                 ? loadingProgress
                  //                                           .cumulativeBytesLoaded /
                  //                                       loadingProgress
                  //                                           .expectedTotalBytes!
                  //                                 : null,
                  //                           ),
                  //                         ),
                  //                       );
                  //                     },
                  //                   ),
                  //                   // Gradient Overlay
                  //                   Container(
                  //                     decoration: BoxDecoration(
                  //                       gradient: LinearGradient(
                  //                         begin: Alignment.topCenter,
                  //                         end: Alignment.bottomCenter,
                  //                         colors: [
                  //                           Colors.transparent,
                  //                           Colors.black.withOpacity(0.7),
                  //                         ],
                  //                         stops: [0.5, 1.0],
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   // Text Label
                  //                   Positioned(
                  //                     bottom: 8,
                  //                     left: 8,
                  //                     right: 8,
                  //                     child: Text(
                  //                       controller
                  //                               .diseaseProductList[index]
                  //                               .diseasesName ??
                  //                           "",
                  //                       style: TextStyle(
                  //                         color: Colors.white,
                  //                         fontSize: 14,
                  //                         fontWeight: FontWeight.w600,
                  //                         shadows: [
                  //                           Shadow(
                  //                             color: Colors.black
                  //                                 .withOpacity(0.5),
                  //                             offset: Offset(0, 1),
                  //                             blurRadius: 2,
                  //                           ),
                  //                         ],
                  //                       ),
                  //                       textAlign: TextAlign.center,
                  //                       maxLines: 2,
                  //                       overflow: TextOverflow.ellipsis,
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ),
                  // SliverToBoxAdapter(child: SizedBox(height: 10)),
                ],
              ),
            );
          },
        ),
        drawer: Obx(
          () => CustomDrawer(
            name: editProfileController.m1.value?.customerName ?? "Name",
            phone: "+91-${_controller.customerModel!.value.customerPhoneNo!}",
            language: languageController.languageName.value == "en"
                ? "English"
                : languageController.languageName.value == "hi"
                ? "हिंदी"
                : "ગુજરાતી",
          ),
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 10,
          onPressed: () {
            Get.to(FaqScreen(), transition: Transition.rightToLeftWithFade);
          },
          backgroundColor: COLOR.appBaseColor,
          child: Icon(Icons.help, color: COLOR.background),
        ),
      ),
    );
  }

  Widget buildIndicator() {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return AnimatedSmoothIndicator(
          activeIndex: controller.activeIndex.value,
          count: controller.offerList.length,
          effect: ExpandingDotsEffect(
            dotWidth: 6,
            dotHeight: 4,
            activeDotColor: COLOR.appBaseColor,
            dotColor: COLOR.grey.withOpacity(0.5),
          ),
        );
      },
    );
  }

  Widget buildIndicatorEducation() {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return AnimatedSmoothIndicator(
          activeIndex: controller.educationIndex.value,
          count: controller.educationList.length,
          effect: ExpandingDotsEffect(
            dotWidth: 6,
            dotHeight: 4,
            activeDotColor: COLOR.appBaseColor,
            dotColor: COLOR.grey.withOpacity(0.5),
          ),
        );
      },
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final String name;
  final String phone;
  final String language;

  final EditProfileController editProfileController = Get.find();
  final DashboardController dashboardController = Get.find();

  CustomDrawer({
    super.key,
    required this.name,
    required this.phone,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.sizeOf(context).width * 0.8,
      child: Column(
        children: [
          Obx(
            () => Align(
              alignment: Alignment.center,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      COLOR.appBaseColor,
                      COLOR.appBaseColor.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 36,
                          backgroundImage:
                              (editProfileController.m1.value?.customerImage !=
                                      null &&
                                  editProfileController
                                      .m1
                                      .value!
                                      .customerImage!
                                      .isNotEmpty)
                              ? NetworkImage(
                                      editProfileController
                                              .m1
                                              .value!
                                              .customerImage!
                                              .startsWith('http')
                                          ? editProfileController
                                                .m1
                                                .value!
                                                .customerImage!
                                          : "$IMAGE_URL${editProfileController.m1.value!.customerImage}",
                                    )
                                    as ImageProvider
                              : AssetImage(Images.profileicon),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name.isNotEmpty ? name : StringRes.enterYourName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              phone,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              language,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Menu Items List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Obx(
                  () => editProfileController.m1.value?.role == "carpenter"
                      ? Column(
                          children: [
                            _drawerTile(
                              Icons.qr_code_scanner_rounded,
                              "Scan Barcode",
                              voidCallback: () {
                                Get.to(() => const QRScannerView());
                              },
                            ),
                            _drawerTile(
                              Icons.redeem_rounded,
                              "Withdraw Points",
                              voidCallback: () {
                                Get.to(() => const WithdrawPointScreen());
                              },
                            ),
                            const Divider(),
                          ],
                        )
                      : const SizedBox(),
                ),
                _drawerTile(Icons.article, StringRes.terms),
                _drawerTile(Icons.lock, StringRes.privacyPolicy),
              ],
            ),
          ),

          // 🔹 Logout Button
          Padding(
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 18,
              right: 16,
              left: 16,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showLogoutBottomSheet(context);
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                label: Text(
                  StringRes.logout,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  elevation: 3,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(
    IconData icon,
    String title, {
    final VoidCallback? voidCallback,
  }) {
    return ListTile(
      leading: Icon(icon, color: COLOR.appBaseColor),
      title: Text(title),
      onTap: voidCallback,
      //     () {
      //   // TODO: Navigation
      // },
    );
  }

  Widget changeLanguageButton(VoidCallback onTap) {
    return Material(
      color: Colors.transparent, // Transparent background for ripple effect
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        // Ripple effect ke liye
        splashColor: COLOR.appBaseColor.withOpacity(0.2),
        // Ripple ka color
        highlightColor: COLOR.appBaseColor.withOpacity(0.1),
        // Button press effect
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.language, size: 30, color: COLOR.appBaseColor),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: COLOR.appBaseColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "अ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2),
                          Text(
                            "A",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                StringRes.changeLanguage,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutBottomSheet(BuildContext context) {
    LanguageController languageController = Get.find();
    Get.bottomSheet(
      SafeArea(
        bottom: true,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                StringRes.logoutConfirmation,

                // "Are you sure you want to logout?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.black),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      StringRes.cancel,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: COLOR.appBaseColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      SharedHelper helper = SharedHelper();
                      languageController.changeLanguage("ગુજરાતી");
                      await helper
                          .deleteCustomer(); // agar yeh async method hai\
                      // await helper.storeBool(value: true,key: SharedHelper.deleteAccountKey);
                      // await authenticate.signOut();
                      Get.offAll(() => LoginScreen());
                      // Logout logic here
                      Get.back();
                    },
                    child: Text(
                      StringRes.logout,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      enterBottomSheetDuration: Duration(milliseconds: 300),
      exitBottomSheetDuration: Duration(milliseconds: 300),
    );
  }
}
