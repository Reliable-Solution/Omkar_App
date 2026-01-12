import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:omkar_app/controller/coinHiostoryControler.dart';
import 'package:omkar_app/widget/appBarWidget.dart';

import '../../constant/colorConst.dart';
import '../../utils/string_res.dart';

class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key});

  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  final CoinHistoryController controller = Get.put(CoinHistoryController());

  Future<void> _onRefresh() async {
    controller.getData();
    // await controller.fetchHistory(customerId: controller.customerModel?.value.customerId ?? "",);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // controller.getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MyCustomAppBar(
          actionPadding: 10,
          height: 100,
          appbarPadding: 0,
          elevation: 1,
          text: StringRes.pointHistory,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: COLOR.appBaseColor),
            );
          }

          if (controller.historyList.isEmpty) {
            return Center(child: Text(StringRes.noHistoryAvailable));
          }

          Widget listView = ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: controller.historyList.length,
            itemBuilder: (context, index) {
              final item = controller.historyList[index];
              final int points = int.tryParse(item.pointTotal ?? '0') ?? 0;
              // Determine if positive: based on PointType or make it dynamic
              final bool isPositive =
                  (item.pointType == 'Earned' ||
                  item.pointType ==
                      'ReferralEarned'); // Adjust logic as per your API (e.g., check description or a field)
              final String dateTimeStr =
                  item.pointCDT ?? ''; // This contains the full datetime string
              print('PointCDT: $dateTimeStr');

              // Parse date and time from pointCDT (format: 'yyyy-MM-dd HH:mm:ss')
              String date = 'Unknown';
              String time = 'Unknown';

              if (dateTimeStr.isNotEmpty) {
                final dateTimeParts = dateTimeStr.split(' ');
                if (dateTimeParts.length >= 2) {
                  // Format date part (first part)
                  date = _formatDate(dateTimeParts[0]);
                  // Format time part (second part)
                  time = _formatTime(dateTimeParts[1]);
                }
              }

              print('Parsed - Date: $date, Time: $time');

              return Column(
                children: [
                  _buildPointCard(
                    isPositive: isPositive,
                    points: points,
                    message: item.pointDescription ?? 'No message',
                    date: date,
                    time: time,
                  ),
                  const SizedBox(height: 12.0),
                ],
              );
            },
          );

          if (controller.historyList.isEmpty) {
            listView = Center(child: Text(StringRes.noHistoryAvailable));
          }

          // Wrap with RefreshIndicator
          return RefreshIndicator(
            onRefresh: () => _onRefresh(),
            child: listView,
          );
        }),
      ),
    );
  }

  // Helper to format date like '10 Oct'
  String _formatDate(String dateStr) {
    try {
      final DateTime dt = DateTime.parse(dateStr);
      return '${dt.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][dt.month - 1]}';
    } catch (e) {
      return dateStr;
    }
  }

  // Helper to format time like '08:02 PM'
  // String _formatTime(String timeStr) {
  //   try {
  //     final List<String> parts = timeStr.split(':');
  //     int hour = int.parse(parts[0]);
  //     final minute = parts[1];
  //     final period = hour >= 12 ? 'PM' : 'AM';
  //     hour = hour > 12 ? hour - 12 : hour;
  //     hour = hour == 0 ? 12 : hour;
  //     return '${hour.toString().padLeft(2, '0')}:$minute $period';
  //   } catch (e) {
  //     return timeStr;
  //   }
  // }

  String _formatTime(String dateTimeStr) {
    try {
      // Split the date and time parts
      final parts = dateTimeStr.split(' ');
      if (parts.length >= 2) {
        final timePart = parts[1]; // Get the time part (HH:MM:SS)
        final timeComponents = timePart.split(':');
        if (timeComponents.length >= 2) {
          int hour = int.tryParse(timeComponents[0]) ?? 0;
          final minute = timeComponents[1];
          final period = hour >= 12 ? 'PM' : 'AM';
          hour = hour > 12 ? hour - 12 : hour;
          hour = hour == 0 ? 12 : hour;
          return '${hour.toString().padLeft(2, '0')}:$minute $period';
        }
      }
      return dateTimeStr; // Return original if parsing fails
    } catch (e) {
      debugPrint('Error formatting time: $e');
      return dateTimeStr;
    }
  }

  Widget _buildPointCard({
    required bool isPositive,
    required int points,
    required String message,
    required String date,
    required String time,
  }) {
    final Color pointsColor = isPositive
        ? const Color(0xFF388E3C)
        : const Color(0xFFD32F2F);
    final String pointsText = isPositive ? '+$points Points' : '$points Points';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            spreadRadius: 1,
            color: Colors.black12,
            offset: Offset(0, 0),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pointsText,
            style: TextStyle(
              color: pointsColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF424242),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'On $date, $time',
            style: const TextStyle(
              color: Color(0xFF757575),
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
