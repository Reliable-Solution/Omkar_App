import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:omkar_app/constant/colorConst.dart';
import 'package:omkar_app/utils/binding/networkBinding.dart';
import 'package:omkar_app/utils/services/firebase_notification.dart';
import 'package:omkar_app/utils/services/languageServices.dart';
import 'package:omkar_app/view/splash/splashScreen.dart';

import 'Theme/nativeTheme.dart';
import 'controller/homeController.dart';
import 'controller/languageController.dart';

Uri? _initialLink;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fluttertoast.getInstance().init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  print("🟡 Initializing language...");

  await Get.putAsync(() async => LanguageController());
  await LocalizationService.loadTranslations();

  try {
    print(" Initializing Firebase...");
    await Firebase.initializeApp();

    if (Platform.isAndroid) {
      print("✅ Firebase initialized on Android ");
    } else if (Platform.isIOS) {
      print("✅ Firebase initialized on iOS ");

      // Request user permission for iOS notifications (AFTER Firebase init)
      try {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        print("✅ iOS notification permission requested");
      } catch (e) {
        print("⚠️ iOS notification permission error: $e");
      }

      // Get APNS token for iOS - Essential for Phone Auth
      // WAIT LONGER - Give iOS more time to get APNS token
      try {
        // First attempt
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

        if (apnsToken != null && apnsToken.isNotEmpty) {
          print("✅ APNS Token received: ${apnsToken.substring(0, 20)}...");
        } else {
          print("⚠️ APNS Token not available on first attempt, waiting...");

          // Wait a bit longer and try again
          await Future.delayed(const Duration(seconds: 2));

          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null && apnsToken.isNotEmpty) {
            print(
              "✅ APNS Token received after delay: ${apnsToken.substring(0, 20)}...",
            );
          } else {
            print("⚠️ APNS Token not available - Will use reCAPTCHA fallback");
          }
        }
      } catch (e) {
        print("⚠️ APNS Token error: $e");
        print("ℹ️ Phone Auth will use reCAPTCHA fallback");
      }

      // Additional delay to ensure AppDelegate has set up APNS
      await Future.delayed(const Duration(milliseconds: 500));
      print("✅ iOS notification setup complete - Phone Auth ready");
    }

    // Initialize notifications with error handling
    try {
      FirebaseNotification().initNotifications();
    } catch (e) {
      print("⚠️ Firebase notifications initialization error: $e");
    }

    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
      print("✅ Firebase App Check activated in Debug Mode");
    } catch (e) {
      print("⚠️ Firebase App Check activation error: $e");
    }
    print("✅ Firebase initialized successfully.");
  } catch (e) {
    print("❌ Firebase init error: $e");
    rethrow;
  }

  try {
    await GetStorage.init();
    print(" GetStorage initialized.");
  } catch (e) {
    print(" GetStorage init error: $e");
  }

  // Add this for debugging Firebase issues
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    print('Auth state changed: ${user?.uid}');
  });

  // Get initial deep link before running the app
  final appLinks = AppLinks();
  _initialLink = await appLinks.getInitialLink();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();

    // Handle initial link after the first frame (ensures GetX is ready)
    if (_initialLink != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleDeepLink(_initialLink!);
      });
    }

    // Listen for incoming links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print("========>>> Mounted ");
      if (mounted) {
        _handleDeepLink(uri);
      }
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: LocalizationService(),
      locale: Get.locale ?? Locale('en', 'US'),
      fallbackLocale: Locale('en', 'US'),
      home: SplashScreen(),
      // home: PointHistoryScreen(),
      theme: ThemeData(
        colorSchemeSeed: COLOR.appBaseColor,
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: COLOR.white),
          titleTextStyle: Themes.light.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: COLOR.white,
            fontSize: 20,
          ),
        ),
      ),
      initialBinding: NetworkBinding(),
    );
  }
}

void _handleDeepLink(Uri link) async {
  print("========> Deep link received: $link"); // Check console
  print("========> Scheme: ${link.scheme}");

  print("========> Scheme Path Name : ${link.path}");
  String schemeUrl = link.scheme.toString();
  print(schemeUrl.compareTo("ewaappliances") == 0);
  if (schemeUrl.compareTo("ewaappliances") == 0) {
    final productId = link.pathSegments.last;
    final homeController = Get.find<HomeController>();
    await homeController.getProductData(productId);
  }
}

// import 'package:flutter/material.dart';

class PointHistoryScreen extends StatelessWidget {
  const PointHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // const Color(0xFFEEEEEE).withOpacity(0.9),
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          _buildPointCard(
            isPositive: true,
            points: 100,
            message: 'Hitesh You got the points messege',
            date: '10 Oct',
            time: '08:02 PM',
          ),
          const SizedBox(height: 12.0),
          _buildPointCard(
            isPositive: false,
            points: -10,
            message: 'Hitesh You got the points messege',
            date: '10 Oct',
            time: '08:02 PM',
          ),
          const SizedBox(height: 12.0),
          _buildPointCard(
            isPositive: true,
            points: 100,
            message: 'Hitesh You got the points messege',
            date: '10 Oct',
            time: '08:02 PM',
          ),
          const SizedBox(height: 12.0),
          _buildPointCard(
            isPositive: false,
            points: -10,
            message: 'Hitesh You got the points messege',
            date: '10 Oct',
            time: '08:02 PM',
          ),
        ],
      ),
    );
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
