import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Skip initialization on Web & non-mobile platforms (not supported)
    if (kIsWeb) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> showLowStockNotification({
    required int id,
    required String productName,
    required int currentStock,
  }) async {
    // Notifikasi lokal hanya didukung di platform mobile (Android/iOS)
    if (kIsWeb) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'low_stock_channel',
      'Stok Menipis',
      channelDescription: 'Notifikasi ketika stok produk hampir habis',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      'Stok Menipis: $productName',
      'Sisa stok tinggal $currentStock unit. Segera lakukan restock!',
      platformChannelSpecifics,
    );
  }
}
