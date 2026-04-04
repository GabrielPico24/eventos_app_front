import 'package:firebase_messaging/firebase_messaging.dart';

class PushBootstrap {
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;
}