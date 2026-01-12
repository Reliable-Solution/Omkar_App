import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:omkar_app/utils/string_res.dart';
import 'package:omkar_app/view/leadership%20&%20reward/reward.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/colorConst.dart';
import '../../controller/leadeController.dart';
import 'leadership.dart';

// import 'constant/colorConst.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Tabs Demo',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: TabMainScreen(),
//     );
//   }
// }

/* -------------------------------------------------
   Tab Main Screen
-------------------------------------------------- */
class TabMainScreen extends StatefulWidget {
  const TabMainScreen({super.key});

  @override
  State<TabMainScreen> createState() => _TabMainScreenState();
}

class _TabMainScreenState extends State<TabMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final controller = Get.put(LeaderboardController());

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
  // Future<void> _showMonthYearPicker(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime(controller.selectedYear.value, int.parse(controller.selectedMonth.value)),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime.now(),
  //     initialDatePickerMode: DatePickerMode.year, // Start with year selection
  //     builder: (context, child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           primaryColor: COLOR.appBaseColor,
  //           colorScheme: ColorScheme.light(primary: COLOR.appBaseColor),
  //           buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //
  //   if (picked != null) {
  //     final String month = DateFormat('MM').format(picked); // Get month as 'MM'
  //     final int year = picked.year;
  //     controller.updateDate(year, month); // Update controller with new month/year
  //   }
  // }

  // Custom Month/Year Picker Dialog
  // Future<void> _showMonthYearPicker(BuildContext context) async {
  //   int selectedYear = controller.selectedYear.value;
  //   int selectedMonth = int.parse(controller.selectedMonth.value) - 1; // 0-based index for months
  //
  //   final List<String> months = [
  //     'January', 'February', 'March', 'April', 'May', 'June',
  //     'July', 'August', 'September', 'October', 'November', 'December'
  //   ];
  //   final List<int> years = List.generate(26, (index) => 2000 + index); // 2000 to 2025
  //
  //   await showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Select Month & Year'),
  //       content: SizedBox(
  //         height: 200,
  //         width: 300,
  //         child: Row(
  //           children: [
  //             // Month Picker
  //             Expanded(
  //               child: CupertinoPicker(
  //                 itemExtent: 32.0,
  //                 scrollController: FixedExtentScrollController(initialItem: selectedMonth),
  //                 onSelectedItemChanged: (index) {
  //                   selectedMonth = index;
  //                 },
  //                 children: months.map((month) => Center(child: Text(month))).toList(),
  //               ),
  //             ),
  //             // Year Picker
  //             Expanded(
  //               child: CupertinoPicker(
  //                 itemExtent: 32.0,
  //                 scrollController: FixedExtentScrollController(
  //                   initialItem: years.indexOf(selectedYear),
  //                 ),
  //                 onSelectedItemChanged: (index) {
  //                   selectedYear = years[index];
  //                 },
  //                 children: years.map((year) => Center(child: Text(year.toString()))).toList(),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             final monthStr = (selectedMonth + 1).toString().padLeft(2, '0'); // Convert to MM format
  //             controller.updateDate(selectedYear, monthStr);
  //             Navigator.pop(context);
  //           },
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // Custom Month/Year Picker Dialog with Dropdowns
  // Future<void> _showMonthYearPicker(BuildContext context) async {
  //   String selectedMonth = controller.selectedMonth.value;
  //   int selectedYear = controller.selectedYear.value;
  //
  //   final List<Map<String, String>> months = [
  //     {'name': 'January', 'value': '01'},
  //     {'name': 'February', 'value': '02'},
  //     {'name': 'March', 'value': '03'},
  //     {'name': 'April', 'value': '04'},
  //     {'name': 'May', 'value': '05'},
  //     {'name': 'June', 'value': '06'},
  //     {'name': 'July', 'value': '07'},
  //     {'name': 'August', 'value': '08'},
  //     {'name': 'September', 'value': '09'},
  //     {'name': 'October', 'value': '10'},
  //     {'name': 'November', 'value': '11'},
  //     {'name': 'December', 'value': '12'},
  //   ];
  //   final List<int> years = List.generate(26, (index) => 2000 + index); // 2000–2025
  //
  //   await showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Select Month & Year'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           // Month Dropdown
  //           DropdownButton<String>(
  //             value: selectedMonth,
  //             isExpanded: true,
  //             hint: const Text('Select Month'),
  //             items: months.map((month) {
  //               return DropdownMenuItem<String>(
  //                 value: month['value'],
  //                 child: Text(month['name']!),
  //               );
  //             }).toList(),
  //             onChanged: (value) {
  //               if (value != null) {
  //                 selectedMonth = value;
  //               }
  //             },
  //           ),
  //           const SizedBox(height: 16),
  //           // Year Dropdown
  //           DropdownButton<int>(
  //             value: selectedYear,
  //             isExpanded: true,
  //             hint: const Text('Select Year'),
  //             items: years.map((year) {
  //               return DropdownMenuItem<int>(
  //                 value: year,
  //                 child: Text(year.toString()),
  //               );
  //             }).toList(),
  //             onChanged: (value) {
  //               if (value != null) {
  //                 selectedYear = value;
  //               }
  //             },
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             controller.updateDate(selectedYear, selectedMonth);
  //             Navigator.pop(context);
  //           },
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Custom Month/Year Picker Dialog with Dropdowns
  Future<void> _showMonthYearPicker(BuildContext context) async {
    String selectedMonth = controller.selectedMonth.value;
    int selectedYear = controller.selectedYear.value;

    final List<Map<String, String>> months = [
      {'name': 'January', 'value': '01'},
      {'name': 'February', 'value': '02'},
      {'name': 'March', 'value': '03'},
      {'name': 'April', 'value': '04'},
      {'name': 'May', 'value': '05'},
      {'name': 'June', 'value': '06'},
      {'name': 'July', 'value': '07'},
      {'name': 'August', 'value': '08'},
      {'name': 'September', 'value': '09'},
      {'name': 'October', 'value': '10'},
      {'name': 'November', 'value': '11'},
      {'name': 'December', 'value': '12'},
    ];
    final List<int> years = List.generate(
      DateTime.now().year - 1999,
      (index) => 2000 + index,
    ); // 2000 to current year

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(StringRes.selectMonthYear),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Month Dropdown
              DropdownButton<String>(
                value: selectedMonth,
                isExpanded: true,
                hint: Text(StringRes.selectMonth),
                items: months.map((month) {
                  return DropdownMenuItem<String>(
                    value: month['value'],
                    child: Text(month['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedMonth = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Year Dropdown
              DropdownButton<int>(
                value: selectedYear,
                isExpanded: true,
                hint: Text(StringRes.selectYear),
                items: years.map((year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedYear = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(StringRes.cancel),
            ),
            TextButton(
              onPressed: () {
                controller.updateDate(selectedYear, selectedMonth);
                Navigator.pop(context);
              },
              child: Text(StringRes.okTap),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: COLOR.appBaseColor,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Text(
            StringRes.leaderShipRewards,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          bottom: TabBar(
            controller: tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: StringRes.leadership),
              Tab(text: StringRes.rewards),
            ],
          ),
          actions: [
            Obx(
              () => Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  DateFormat('MMMM yyyy').format(
                    DateTime(
                      controller.selectedYear.value,
                      int.parse(controller.selectedMonth.value),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),

            // padding: const EdgeInsets.all(8.0),
            // child:
            IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.white),
              onPressed: () => _showMonthYearPicker(context),
            ),
          ],
        ),
        body: TabBarView(
          controller: tabController,
          children: const [LeadershipScreen(), RewardScreen()],
        ),
      ),
    );
  }
}
