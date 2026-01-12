import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omkar_app/controller/addressController.dart';
import 'package:omkar_app/Theme/nativeTheme.dart';
import 'package:omkar_app/constant/colorConst.dart';
import 'package:omkar_app/utils/string_res.dart';
import 'package:omkar_app/view/checkout/paymentScreen.dart';
import 'package:omkar_app/widget/buttonWidget.dart';
import 'package:omkar_app/widget/appBarWidget.dart';
import 'package:omkar_app/widget/textWidget.dart';
import '../../constant/colorConst.dart';
import '../../widget/selectAddress.dart';
import '../address/pickupAddressScreen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final AddressController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.getAllAddress();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: MyCustomAppBar(
          actionPadding: 10,
          height: 100,
          appbarPadding: 0,
          elevation: 1,
          text: StringRes.selectDeliveryAddress,
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          action: [
            IconButton(
              onPressed: () {
                clearTextFields(controller);
                Get.to(() => PickupAddressScreen())?.then((_) {
                  controller.getAllAddress();
                });
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
        body: GetBuilder<AddressController>(
          builder: (controller) => Column(
            children: [
              // Checkout progress indicator
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProgressStep(1, StringRes.cart, false, true),
                    _buildProgressLine(true),
                    _buildProgressStep(2, StringRes.address, true, false),
                    _buildProgressLine(false),
                    _buildProgressStep(3, StringRes.payment, false, false),
                    _buildProgressLine(false),
                    _buildProgressStep(4, StringRes.summary, false, false),
                  ],
                ),
              ),

              // Add new address button
              // Container(
              //   width: double.infinity,
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //   color: Colors.white,
              //   child: GestureDetector(
              //     onTap: () {
              //       clearTextFields(controller);
              //       Get.to(() => PickupAddressScreen())?.then((_) {
              //         controller.getAllAddress();
              //       });
              //     },
              //     child: Text(
              //       "* ${StringRes.addAddress}",
              //       style: TextStyle(
              //         color: COLOR.appBaseColor,
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 8),

              // Address list
              Expanded(
                child: Obx(() {
                  if (controller.allAddressList.isEmpty) {
                    return Center(child: Text(StringRes.noAddressesFound));
                  }
                  return ListView.builder(
                    itemCount: controller.allAddressList.length,
                    itemBuilder: (context, index) {
                      final address = controller.allAddressList[index];
                      final isSelected =
                          controller.selectedAddressId.value ==
                          address.addressId.toString();

                      return GestureDetector(
                        onTap: () {
                          if (controller.selectedAddressId.value !=
                              address.addressId.toString()) {
                            controller.selectedAddressId.value = address
                                .addressId
                                .toString();
                          } else {
                            controller.selectedAddressId.value = '';
                          }
                          controller.update();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                            bottom: 8,
                            left: 8,
                            right: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xffe8eeff)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  address.addressFullName ?? StringRes.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "${address.addressColony ?? ''},"
                                    // " ${address.cityName ?? ''}, ${address.stateName ?? ''}, "
                                    "${address.addressPincode ?? ''}\n"
                                    // "New York ${address.addressPincode ?? ''}\n"
                                    "${address.addressMobileNo ?? ''}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: COLOR.appBaseColor,
                                          width: 2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: EdgeInsets.all(3),
                                      child: CircleAvatar(
                                        radius: 4,
                                        backgroundColor: isSelected
                                            ? COLOR.appBaseColor
                                            : COLOR.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                                // trailing: Radio<bool>(
                                //   value: true,
                                //   groupValue: isSelected,
                                //   activeColor: COLOR.appBaseColor,
                                //   fillColor:
                                //       WidgetStateProperty.resolveWith<Color>(
                                //     (Set<WidgetState> states) {
                                //       // if (isSelected) return Colors.white;
                                //       return COLOR.appBaseColor;
                                //     },
                                //   ),
                                //   onChanged: (value) {
                                //     if (controller.selectedAddressId.value !=
                                //         address.addressId.toString()) {
                                //       controller.selectedAddressId.value =
                                //           address.addressId.toString();
                                //     } else {
                                //       controller.selectedAddressId.value = '';
                                //     }
                                //     controller.update();
                                //   },
                                // ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  bottom: 8,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    // Navigate to edit address screen with pre-filled data
                                    Get.to(
                                      () =>
                                          PickupAddressScreen(address: address),
                                    )?.then((_) {
                                      controller.getAllAddress();
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        '✏️',
                                        style: TextStyle(
                                          color: COLOR.appBaseColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        StringRes.edit,
                                        style: TextStyle(
                                          color: COLOR.appBaseColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                          decorationColor: COLOR.appBaseColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // if (isSelected)
                              //   Padding(
                              //     padding: const EdgeInsets.symmetric(
                              //         horizontal: 16, vertical: 8),
                              //     child: SizedBox(
                              //       width: double.infinity,
                              //       child: ButtonWidgets(
                              //         title: StringRes.deliverToThisAddress,
                              //         style: Themes
                              //             .light.textTheme.displayLarge!
                              //             .copyWith(
                              //           color: Colors.white,
                              //         ),
                              //         voidCallback: () {
                              //           controller.selectedAddressId.value =
                              //               address.addressId.toString();
                              //           Get.to(() => const PaymentScreen());
                              //         },
                              //         color: COLOR.appBaseColor,
                              //       ),
                              //     ),
                              //   ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: BottomNavigationBar(items: [
        //   BottomNavigationBarItem(
        //       icon: Icon(Icons.add_location_alt_outlined),
        //       label: "Add Address"),
        //   BottomNavigationBarItem(
        //       icon: Icon(Icons.add_location_alt_outlined),
        //       label: "Add Address"),
        // ]),
        bottomSheet: GetBuilder<AddressController>(
          builder: (controller) {
            return Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.transparent),
              child: ButtonWidgets(
                title: StringRes.deliverToThisAddress,
                style: Themes.light.textTheme.displayLarge!.copyWith(
                  color: Colors.white,
                ),
                voidCallback: () {
                  if (controller.selectedAddressId.isNotEmpty) {
                    Get.to(() => const PaymentScreen());
                  }
                },
                color: controller.selectedAddressId.isEmpty
                    ? COLOR.grey
                    : COLOR.appBaseColor,
              ),
            );
          },
        ),
      ),
      // ),
    );
  }

  Widget _buildProgressStep(
    int step,
    String label,
    bool isActive,
    bool isCompleted,
  ) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? COLOR.appBaseColor
                : (isCompleted ? COLOR.appBaseColor : Colors.grey.shade300),
            border: Border.all(
              color: isActive || isCompleted
                  ? COLOR.appBaseColor
                  : Colors.grey.shade400,
              width: 1,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive || isCompleted
                ? COLOR.appBaseColor
                : Colors.grey.shade600,
            fontWeight: isActive || isCompleted
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      width: 40,
      height: 1,
      color: isActive ? COLOR.appBaseColor : Colors.grey.shade300,
    );
  }
}
