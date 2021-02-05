import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

FirebaseMessaging firebaseMessaging;

Future<void> initNotification() async {
  firebaseMessaging = FirebaseMessaging()
    ..requestNotificationPermissions()
    ..onIosSettingsRegistered.listen(
      (IosNotificationSettings settings) {
        const IosNotificationSettings(
          sound: true,
          badge: true,
          alert: true,
        );
      },
    )
    ..configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
      },
      onBackgroundMessage:
          Platform.isAndroid ? myBackgroundMessageHandler : null,
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
      },
    );
  final token = await firebaseMessaging.getToken();
  print(token);
  await FirebaseFirestore.instance
      .collection('customerInfo')
      .doc(FirebaseAuth.instance.currentUser.uid)
      .update({'token': token});
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // データメッセージをハンドリング
    final dynamic data = message['data'];
    print(data);
  }

  if (message.containsKey('notification')) {
    // 通知メッセージをハンドリング
    final dynamic notification = message['notification'];
    print(notification);
  }
  print('onBackground: $message');
}
