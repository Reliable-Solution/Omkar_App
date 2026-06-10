// // import 'dart:math' as Importance;
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:flutter/scheduler.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class FirebaseNotification {
//
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   void initNotifications() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     // Get FCM token
//     // fcmToken = await messaging.getToken();
//     // print("🔑 FCM Token: $fcmToken");
//
//     // Android settings
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     final DarwinInitializationSettings initializationSettingsIOS =
//     DarwinInitializationSettings();
//
//     final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("🔔 Foreground message: ${message.notification?.title}");
//       print("🔔====> Foreground message: ${message.notification?.body}");
//
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;
//
//       if (notification != null && android != null) {
//         flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               'high_importance_channel',
//               'High Importance Notifications',
//               importance: Importance.max,
//               priority: Priority.high,
//               icon: '@mipmap/ic_launcher',
//             ),
//           ),
//         );
//       }
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       print('🔓 Notification clicked!');
//       // Navigate to specific screen if needed
//     });
//   }
// }
// // }
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FirebaseNotification {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Download and save image for notifications
  Future<String?> _downloadAndSaveImage(
      String imageUrl, String fileName) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        print('Failed to download image: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print(":bell: Handling background message: ${message.notification?.title}");
    // Note: Local notifications in background require additional setup
    // You can call flutterLocalNotificationsPlugin.show() here if initialized
  }

  Future<void> initNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request notification permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print(
        ':bell: Notification permission status: ${settings.authorizationStatus}');

    // Get and log FCM token with error handling
    String? fcmToken;
    try {
      // On iOS, wait for APNS token to be set
      if (Platform.isIOS) {
        fcmToken = await messaging.getToken();
      } else {
        fcmToken = await messaging.getToken();
      }
      print(":key: FCM Token: $fcmToken");
    } catch (e) {
      print(":warning: Error getting FCM token: $e");
      // Token will be retrieved when available
    }

    // Set up Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Must match AndroidNotificationDetails
      'High Importance Notifications',
      description: 'Channel for high priority notifications',
      importance: Importance.max,
    );

    // Create the Android notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request Android 13+ notification permission
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize flutter_local_notifications
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print(':bell: Notification tapped: ${response.payload}');
        // Handle notification tap (e.g., navigate to a screen)
      },
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(":bell: Foreground message: ${message.toMap()}");

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        NotificationDetails notificationDetails;
        String? imageUrl =
            message.data['image'] ?? message.notification?.android?.imageUrl;

        if (Platform.isAndroid && android != null) {
          if (imageUrl != null && imageUrl.isNotEmpty) {
            // Handle image notification
            String? imagePath =
                await _downloadAndSaveImage(imageUrl, 'notification_image.jpg');
            notificationDetails = NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'High Importance Notifications',
                channelDescription: 'Channel for high priority notifications',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
                styleInformation: imagePath != null
                    ? BigPictureStyleInformation(
                        FilePathAndroidBitmap(imagePath),
                        largeIcon: FilePathAndroidBitmap(imagePath),
                        contentTitle: notification.title,
                        summaryText: notification.body,
                      )
                    : null,
              ),
            );
          } else {
            // Handle text notification
            notificationDetails = NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'High Importance Notifications',
                channelDescription: 'Channel for high priority notifications',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            );
          }
        } else if (Platform.isIOS) {
          // Handle iOS notification
          notificationDetails = const NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          );
        } else {
          return; // Unsupported platform
        }

        // Show the notification
        await flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          notificationDetails,
          payload:
              message.data['payload'], // Optional: pass data for tap handling
        );
      }
    });

    // Handle notification tap when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(':unlock: Notification opened: ${message.toMap()}');
      // Navigate to specific screen using message.data if needed
    });

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
