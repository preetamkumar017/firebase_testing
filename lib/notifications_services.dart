import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices
{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: true,
      carPlay: true,
      sound: true,
      provisional: true
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized)
      {
        print("User granted permission");
      }else if(settings.authorizationStatus == AuthorizationStatus.provisional)
        {
          print("User granted provisional permission");
        }else
          {
            print("user denied permission");
          }
  }

  void initLocalNotification(BuildContext context,RemoteMessage message) async{
    var androidInitializationSettings =const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosDarwinInitializationSettings = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(android: androidInitializationSettings,iOS: iosDarwinInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,onDidReceiveNotificationResponse: (details) {

    },);
  }

  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((event) {
      print(event.notification!.title.toString());
      print(event.notification!.body.toString());
      if (Platform.isAndroid) {
        initLocalNotification(context, event);
        showNotification(event);
      }
    });
  }

  Future<void> showNotification(RemoteMessage message)async{
    AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
        Random.secure().nextInt(10000).toString(), 'High Importance Notification',
    importance: Importance.max);
    
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        androidNotificationChannel.id.toString(),
        androidNotificationChannel.name.toString(),
      channelDescription: "your channel description",
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'tiker'
    );

   const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

   NotificationDetails notificationDetails = NotificationDetails(
     android: androidNotificationDetails,
     iOS: darwinNotificationDetails
   );
    
    Future.delayed(Duration.zero,() {
      _flutterLocalNotificationsPlugin.show(0, message.notification!.title.toString(), message.notification!.body.toString(), notificationDetails);
    },
     );

  }

  Future<String> getDeviceToken() async{
    String? token = await messaging.getToken();
    return token!;
  }
  void isTokenRefresh() async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }
}