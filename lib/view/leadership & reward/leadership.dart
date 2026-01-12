import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:omkar_app/controller/homeController.dart';
import 'package:omkar_app/controller/leadeController.dart';
import 'package:omkar_app/constant/app_constant.dart';
import 'package:omkar_app/constant/colorConst.dart';
import 'package:omkar_app/models/MonthlyUser.dart';
import 'package:omkar_app/models/prizeModel.dart';
import 'package:omkar_app/utils/string_res.dart';

class LeadershipScreen extends StatefulWidget {
  const LeadershipScreen({super.key});

  @override
  State<LeadershipScreen> createState() => _LeadershipScreenState();
}

class _LeadershipScreenState extends State<LeadershipScreen>
    with SingleTickerProviderStateMixin {
  final LeaderboardController controller = Get.put(LeaderboardController());
  final HomeController homeController = Get.find();
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    controller.fetchData();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Method to show Month/Year Picker
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
  Widget _imageWidget(String url) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Container(
        // padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        child: ClipOval(
          // borderRadius: BorderRadius.circular(50),
          child: Image.network(
            url.isEmpty ? "https://via.placeholder.com/150" : "$IMAGE_URL$url",
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Image.asset("assets/images/profile.png"),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: COLOR.appBaseColor,
        body: Obx(() {
          return controller.isLoading.value
              ? Center(
                  child: CircularProgressIndicator(color: COLOR.background),
                )
              : controller.monthlyUsers.isEmpty
              ? Center(
                  child: Text(
                    StringRes.noDataFound,
                    style: TextStyle(color: COLOR.background),
                  ),
                )
              : Column(
                  children: [
                    if (controller.monthlyUsers.length <= 10)
                      Builder(
                        builder: (context) {
                          List<MonthlyUser>? list = controller.monthlyUsers
                              .where(
                                (element) =>
                                    element.customerId ==
                                    homeController
                                        .customerModel!
                                        .value
                                        .customerId,
                              )
                              ?.toList();
                          return (list?.isEmpty ?? true)
                              ? SizedBox()
                              : Container(
                                  margin: EdgeInsets.only(
                                    left: 20,
                                    bottom: 12,
                                    right: 20,
                                    top: 20,
                                    // vertical: 0,horizontal: 20
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 05,
                                  ),
                                  decoration: BoxDecoration(
                                    // gradient: LinearGradient(
                                    //     colors: [Colors.yellow, Colors.black],
                                    //     stops: [0, 0]),
                                    color: Colors.white,
                                    // .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Text(
                                          "${(list![0].rank).toString()}.",
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                        margin: EdgeInsets.all(06),
                                      ),
                                      Row(
                                        children: [
                                          _imageWidget(list[0].customerImage),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                list[0].customerName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                currencyFormatter.format(
                                                  double.parse(
                                                    list[0].totalAmount,
                                                  ),
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                        },
                      ),

                    if (controller.monthlyUsers.length > 10)
                      _buildCurrentUserHighlight(
                        currencyFormatter,
                        controller.monthlyUsers,
                      ),

                    // Top 3 Leaders Section
                    _buildTopLeaders(
                      currencyFormatter,
                      controller.monthlyUsers,
                      controller.prizes,
                    ),
                    // Spacer
                    // const SizedBox(height: 40),
                    // Bottom List Section (Ranks 4-10)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: COLOR.background,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 10,
                              blurRadius: 10,
                            ),
                          ],
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          itemCount: controller.monthlyUsers.length > 3
                              ? controller.monthlyUsers.length - 3
                              : 0,
                          separatorBuilder: (context, index) => const Divider(
                            indent: 20,
                            endIndent: 20,
                            height: 24,
                          ),
                          itemBuilder: (context, index) {
                            final user = controller.monthlyUsers[index + 3];
                            final prize = controller.prizes.firstWhereOrNull(
                              (p) => p.prizePosition == user.rank,
                            );
                            return _LeaderListItem(
                              user: user,
                              prize: prize,
                              currencyFormatter: currencyFormatter,
                            );
                          },
                        ),
                      ),
                    ),
                    // Highlight Current User's Rank (if not in top 10)
                    // if (controller.monthlyUsers.length > 10)
                    //   _buildCurrentUserHighlight(
                    //       currencyFormatter, controller.monthlyUsers),
                  ],
                );
        }),
      ),
    );
  }

  Widget _buildTopLeaders(
    NumberFormat currencyFormatter,
    List<MonthlyUser> users,
    List<Prize> prizes,
  ) {
    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Rank 2 (Left)
          if (users.length > 1)
            Positioned(
              bottom: 10,
              left: 20,
              child: _TopLeaderWithRank(
                user: users[1],
                prize: prizes.firstWhereOrNull((p) => p.prizePosition == 2),
                currencyFormatter: currencyFormatter,
                isRank1: false,
              ),
            ),
          // Rank 1 (Center, Top)
          if (users.isNotEmpty)
            Positioned(
              top: -1,
              child: _TopLeaderWithRank(
                user: users[0],
                prize: prizes.firstWhereOrNull((p) => p.prizePosition == 1),
                currencyFormatter: currencyFormatter,
                isRank1: true,
              ),
            ),
          // Rank 3 (Right)
          if (users.length > 2)
            Positioned(
              bottom: 10,
              right: 08,
              child: _TopLeaderWithRank(
                user: users[2],
                prize: prizes.firstWhereOrNull((p) => p.prizePosition == 3),
                currencyFormatter: currencyFormatter,
                isRank1: false,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserHighlight(
    NumberFormat currencyFormatter,
    List<MonthlyUser> users,
  ) {
    final currentUser = users.firstWhereOrNull(
      (user) =>
          user.customerId == homeController.customerModel!.value.customerId,
    );
    if (currentUser == null) return const SizedBox();

    return Container(
      margin: EdgeInsets.only(
        left: 20,
        bottom: 12,
        right: 20,
        top: 20,
        // vertical: 0,horizontal: 20
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 05),
      decoration: BoxDecoration(
        color: Colors.white,
        // .withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(06),
            child: Text(
              currentUser.rank.toString().padLeft(2, '0'),
              style: const TextStyle(color: Colors.black87),
            ),
          ),
          Row(
            children: [
              _imageWidget('UserImage' ?? ''),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUser.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    currencyFormatter.format(
                      double.parse(currentUser.totalAmount),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopLeaderWithRank extends StatelessWidget {
  final MonthlyUser user;
  final Prize? prize;
  final NumberFormat currencyFormatter;
  final bool isRank1;

  const _TopLeaderWithRank({
    required this.user,
    required this.prize,
    required this.currencyFormatter,
    required this.isRank1,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: isRank1 ? 108 : 100,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 08,
                  vertical: 06,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: isRank1 ? 24 : 18,
                      child: ClipOval(
                        child: Image.network(
                          user.customerImage.isEmpty
                              ? "https://via.placeholder.com/150"
                              : "$IMAGE_URL${user.customerImage}",
                          errorBuilder: (_, __, ___) =>
                              Image.asset("assets/images/profile.png"),
                        ),
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    if (prize != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          "$IMAGE_URL${prize!.prizeImage}",
                          width: isRank1 ? 40 : 35,
                          height: isRank1 ? 40 : 35,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.customerName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isRank1 ? 15 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: COLOR.yellow100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currencyFormatter.format(double.parse(user.totalAmount)),
                  style: TextStyle(
                    color: COLOR.black,
                    fontSize: isRank1 ? 12 : 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(left: -8.5, top: -4.5, child: _RankBadge(rank: user.rank)),
      ],
    );
  }
}

class _LeaderListItem extends StatelessWidget {
  final MonthlyUser user;
  final Prize? prize;
  final NumberFormat currencyFormatter;

  const _LeaderListItem({
    required this.user,
    required this.prize,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            user.rank.toString().padLeft(2, '0'),
            style: TextStyle(
              color: COLOR.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 20,
            child: ClipOval(
              child: Image.network(
                user.customerImage.isEmpty
                    ? "https://via.placeholder.com/150"
                    : "$IMAGE_URL${user.customerImage}",
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset("assets/images/profile.png"),
              ),
            ),
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.customerName,
                  style: TextStyle(
                    color: COLOR.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: COLOR.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    currencyFormatter.format(double.parse(user.totalAmount)),
                    style: TextStyle(
                      color: COLOR.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (prize != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "$IMAGE_URL${prize!.prizeImage}",
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
              ),
            ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final Color backgroundColor;
  final Color textColor;

  const _RankBadge({
    required this.rank,
    this.backgroundColor = const Color(0xff1e4f0b),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 0.4),
      ),
      alignment: Alignment.center,
      child: Text(
        rank.toString().padLeft(2, '0'),
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BorderSweepPainter extends CustomPainter {
  final double sweepAngle;
  final double strokeWidth;
  final Color color;

  _BorderSweepPainter({
    required this.sweepAngle,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      const Radius.circular(20),
    );

    final grayPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, grayPaint);

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withOpacity(0), color, color.withOpacity(0)],
        stops: const [0.0, 0.1, 0.2],
        transform: GradientRotation(sweepAngle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _BorderSweepPainter old) =>
      old.sweepAngle != sweepAngle;
}
