import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omkar_app/controller/dashboardController.dart';
import 'package:omkar_app/models/orderDetailModel.dart';

import '../../constant/app_constant.dart';
import '../../constant/colorConst.dart';
import '../../controller/orderController.dart';
import '../../utils/string_res.dart';

class Orderdetailscreen extends StatefulWidget {
  const Orderdetailscreen({super.key});

  @override
  State<Orderdetailscreen> createState() => _OrderdetailscreenState();
}

class _OrderdetailscreenState extends State<Orderdetailscreen> {
  @override
  Widget build(BuildContext context) {
    return orderDetailsScreen(context);
  }
}

Widget orderDetailsScreen(BuildContext context) {
  OrderController orderController = Get.find();

  return Scaffold(
    backgroundColor: Colors.grey.shade200,
    appBar: AppBar(
      title: Text(StringRes.orderDetails, style: TextStyle(color: COLOR.white)),
      backgroundColor: COLOR.appBaseColor,
    ),
    body: SingleChildScrollView(
      child: Obx(() {
        if (orderController.isDetailLoading.value) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(color: COLOR.appBaseColor),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            // Order Summary
            OrderSummary(ordersDetailsList: orderController.orderDetailList),
            // Cancel Order Button
            cancelOrderButton(context),
            // Delivery Address
            deliveryAddress(context),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.0030),

            // Payment Details
            paymentDetails(context),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        );
      }),
    ),
  );
}

Widget orderTracking(BuildContext context) {
  OrderController orderController = Get.find();

  return orderController.orderDetailList[0].otherDetail![0].orderStage ==
          "PlaceOrder"
      ? Container(
          width: MediaQuery.sizeOf(context).width,
          color: Colors.white,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                StringRes.orderPlaced,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "${StringRes.deliveryBy} ${orderController.orderDetailList[0].otherDetail![0].orderDate}",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  trackingStep(
                    StringRes.ordered,
                    "${orderController.orderDetailList[0].otherDetail![0].orderDate}",
                    true,
                  ),
                  trackingStep(StringRes.shipped, "", false),
                  trackingStep(StringRes.outForDelivery, "", false),
                  trackingStep(
                    StringRes.delivery,
                    "${orderController.orderDetailList[0].otherDetail![0].orderDeliveryDate}",
                    false,
                  ),
                ],
              ),
            ],
          ),
        )
      : SizedBox();
}

// ✅ Tracking Step Widget
Widget trackingStep(String title, String date, bool completed) {
  OrderController orderController = Get.find();

  return orderController.orderDetailList[0].otherDetail![0].orderStage ==
          "PlaceOrder"
      ? Column(
          children: [
            Icon(
              completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: completed ? Colors.green : Colors.grey,
            ),
            Text(title, style: TextStyle(fontSize: 12)),
            Text(date, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        )
      : SizedBox();
}

// ✅ Cancel Order Button
Widget cancelOrderButton(BuildContext context) {
  OrderController orderController = Get.find();
  final orderStatus =
      orderController.orderDetailList[0].otherDetail![0].orderStage;
  print("===>>. $orderStatus");

  return orderStatus == "Cancel"
      ? cancelOrder(context)
      : orderStatus == "PlaceOrder"
      ? GetBuilder<OrderController>(
          builder: (orderController) => Container(
            width: MediaQuery.sizeOf(context).width,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 10,
              children: [
                Expanded(
                  child: Text(StringRes.cancellationAvailableTillShipping),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: COLOR.appBaseColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: COLOR.white,
                            ),
                            padding: EdgeInsets.only(top: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  StringRes.cancelOrder,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 3,
                                    bottom: 30,
                                  ),
                                  child: Text(StringRes.areUSureCancel),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: Get.back,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              // color: COLOR.green50,
                                              color: COLOR.green,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              StringRes.no,
                                              style: TextStyle(
                                                color: COLOR.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Get.back();
                                            orderController.cancelOrder(
                                              orderController
                                                  .customerModel!
                                                  .value
                                                  .customerId,
                                              orderController
                                                  .orderDetailList[0]
                                                  .otherDetail![0]
                                                  .orderId,
                                            );
                                            orderController.getOrder(
                                              orderController
                                                  .customerModel!
                                                  .value
                                                  .customerId,
                                            );
                                            orderController.getOrderDetail(
                                              orderController
                                                  .orderDetailList[0]
                                                  .otherDetail![0]
                                                  .orderId,
                                            );
                                            orderController.update();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: COLOR.green50,

                                              // color: COLOR.green,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              StringRes.yes,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: COLOR.black,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    StringRes.cancelOrder,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        )
      : orderStatus == "Delivered"
      ? Container(
          width: double.infinity,
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(vertical: 08),
          decoration: BoxDecoration(color: COLOR.appBaseColor),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              orderStatus?.toString() ?? "",
              style: TextStyle(
                color: COLOR.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
      : SizedBox();
}

// ✅ Delivery Address Widget
Widget deliveryAddress(BuildContext context) {
  OrderController orderController = Get.find();

  return Container(
    width: MediaQuery.sizeOf(context).width,
    color: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              StringRes.deleiveryAddress,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          "${orderController.orderDetailList[0].shippingDetail![0].addressFullName}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          "${orderController.orderDetailList[0].shippingDetail![0].addressColony?.trim()}"
          ",\n${orderController.orderDetailList[0].shippingDetail![0].pincode}",
        ),
      ],
    ),
  );
}

// ✅ Recently Viewed Items
Widget recentlyViewed() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        StringRes.recentlyViewed,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: List.generate(3, (index) => recentlyViewedItem())),
      ),
    ],
  );
}

// ✅ Recently Viewed Item
Widget recentlyViewedItem() {
  return Container(
    margin: EdgeInsets.only(right: 10),
    width: 100,
    child: Column(
      children: [
        Image.network(
          'https://via.placeholder.com/100',
          width: 100,
          height: 100,
        ),
        Text(StringRes.shirt, style: TextStyle(fontSize: 12)),
      ],
    ),
  );
}

// ✅ Payment Details
Widget paymentDetails(BuildContext context) {
  OrderController orderController = Get.find();

  return Container(
    width: MediaQuery.sizeOf(context).width,
    color: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          StringRes.totalProductPrice,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 5,
              children: [
                Icon(Icons.credit_card, color: Colors.grey),
                Text(
                  StringRes.productPrice,
                  // "Product Price"
                  // "${orderController.orderDetailList[0].otherDetail![0].orderPaymentMethod}",
                ),
              ],
            ),
            Text(
              "+ \t ₹${orderController.orderDetailList[0].otherDetail![0].subTotal}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Row(
        //       spacing: 5,
        //       children: [
        //         Icon(Icons.delivery_dining, color: Colors.grey),
        //         Text(
        //           " Delivery  Charge",
        //         ),
        //       ],
        //     ),
        //     Text(
        //       " + \t ₹${orderController.orderDetailList[0].otherDetail![0].deliveryCharge}",
        //       style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),
        //     ),
        //   ],
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 5,
              children: [
                Icon(Icons.redeem, color: Colors.grey),
                Text(
                  StringRes.reedemPoints,
                  // " Reedem Points",
                ),
              ],
            ),
            Text(
              " - \t ₹${orderController.orderDetailList[0].otherDetail![0].orderTotalPoints}",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 5,
              children: [
                Icon(Icons.delivery_dining, color: Colors.grey),
                Text(
                  StringRes.deliveryCharge,
                  // " Delivery  Charge",
                ),
              ],
            ),
            Text(
              " + \t ₹${orderController.orderDetailList[0].otherDetail![0].deliveryCharge}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 5,
              children: [
                Icon(Icons.money, color: Colors.grey),
                Text(
                  " ${orderController.orderDetailList[0].otherDetail![0].orderPaymentMethod}",
                ),
              ],
            ),
            Text(
              "₹${orderController.orderDetailList[0].otherDetail![0].total}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    ),
  );
}

// ✅ Order Summary Component
class OrderSummary extends StatelessWidget {
  final List<OrderDetailData> ordersDetailsList;

  const OrderSummary({super.key, required this.ordersDetailsList});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.sizeOf(context).width,
      margin: EdgeInsets.all(01),
      // padding: EdgeInsets.all(10),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: ordersDetailsList.length,
        itemBuilder: (context, index) {
          var orderDetail = ordersDetailsList[index].orders;
          if (orderDetail != null && orderDetail.isNotEmpty) {
            return OrderCard(order: orderDetail);
          } else {
            return Center(child: Text(StringRes.noOrderDetailsAvailable));
          }
          // return OrderCard(order: orders[0].orderDetailData![0].orders![index]);
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final List<Orders> order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: order.length,
      itemBuilder: (context, index) {
        print("order dat detailsw ${order[index].productName}");
        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image
                    Container(
                      width: 70,
                      height: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.network(
                        order[index].productdetailImages!.isEmpty
                            ? 'http://surti.idnmserver.com/resources/product_no_image.png'
                            : IMAGE_URL +
                                  (order[index].productdetailImages?[0] ??
                                      'http://surti.idnmserver.com/resources/product_no_image.png'),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset("assets/images/noInternet.jpg");
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // item.productName
                            order[index].productName ?? StringRes.productName,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${order[index].productdetailSrp ?? 0}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            // item.isEasyReturn == 1
                            //     ? "All issue easy returns allowed"
                            //     :
                            StringRes.onlyWrongDefectItemReturnsAllowed,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Quantity : ${order[index].orderdetailQty}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text(
                    //   "${StringRes.soldBy} : ${order[index].productName ?? StringRes.seller}",
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color: Colors.grey.shade700,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget cancelOrder(BuildContext context) {
  return Container(
    width: MediaQuery.sizeOf(context).width,
    // margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 8,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.close, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringRes.cancelled,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  StringRes.asPerYourRequestOnTue,
                  // 'As per your request on',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(
              color: COLOR.appBaseColor,

              // Colors.purple
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: () {
            Get.back();
            Get.find<DashboardController>()
              ..tabIndex = 0
              ..changeTabIndex(0);
            // Get.offAll(DashboardScreen(pageIndex: 0));
            // Navigate to Dashboard
            // Navigator.pushNamed(context, '/dashboard');
          },
          child: Text(
            StringRes.goToDashboard,
            style: TextStyle(
              color: COLOR.appBaseColor,
              // Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
