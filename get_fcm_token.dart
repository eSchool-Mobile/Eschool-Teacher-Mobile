import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'lib/firebase_options.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Get FCM Token
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();

  debugPrint('=================================');
  debugPrint('FCM Token untuk testing:');
  debugPrint(token);
  debugPrint('=================================');
  debugPrint('Project ID: eschool-mobile-fe51a');
  debugPrint('Sender ID: 919419641844');
  debugPrint('Package Name: id.ac.eschool.GuruStaff.android');
  debugPrint('=================================');
}
