
import 'package:firebase_core/firebase_core.dart';
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

  print('=================================');
  print('FCM Token untuk testing:');
  print(token);
  print('=================================');
  print('Project ID: eschool-mobile-fe51a');
  print('Sender ID: 919419641844');
  print('Package Name: id.ac.eschool.GuruStaff.android');
  print('=================================');
}

